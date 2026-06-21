

-- ----------------------------------------------------------
-- P1a — CREATE ROLE: 3 roles del sistema restaurante
-- ----------------------------------------------------------

-- Rol 1: SOLO LECTURA — cajero
-- Ver pedidos y pagos para cobrar, pero no modifica nada
-- ni necesita ver el salario de los empleados.
CREATE ROLE rol_cajero NOLOGIN NOCREATEDB NOCREATEROLE NOSUPERUSER NOREPLICATION;

-- Rol 2: OPERADOR — mesero
-- Inserta y actualiza pedidos/detalle_pedido de la mesa que atiende.
-- No puede borrar registros ni otorgar permisos.
CREATE ROLE rol_mesero NOLOGIN NOCREATEDB NOCREATEROLE NOSUPERUSER NOREPLICATION;

-- Rol 3: ADMINISTRADOR DEL ESQUEMA — admin_restaurante
-- Control total sobre el esquema "restaurante" únicamente.
-- NO es SUPERUSER: no puede tocar otros esquemas ni crear roles nuevos.
CREATE ROLE rol_admin_restaurante NOLOGIN NOCREATEDB NOCREATEROLE NOSUPERUSER NOREPLICATION;

-- Otorgamos uso del esquema a los 3 roles
-- (sin esto, ningún GRANT posterior sobre tablas tiene efecto)
GRANT USAGE ON SCHEMA restaurante TO rol_cajero, rol_mesero, rol_admin_restaurante;

-- El admin del esquema obtiene control total SOLO dentro de "restaurante"
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA restaurante TO rol_admin_restaurante;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA restaurante TO rol_admin_restaurante;
GRANT CREATE ON SCHEMA restaurante TO rol_admin_restaurante;

-- ----------------------------------------------------------
-- P1b — Matriz de privilegios (GRANT / REVOKE)
-- ----------------------------------------------------------

-- ===== rol_cajero: SOLO LECTURA en general =====
GRANT SELECT ON restaurante.pedido TO rol_cajero;
GRANT SELECT ON restaurante.detalle_pedido TO rol_cajero;
GRANT SELECT, INSERT ON restaurante.pago TO rol_cajero;

REVOKE DELETE, UPDATE ON restaurante.pago FROM rol_cajero;
REVOKE INSERT, UPDATE, DELETE ON restaurante.pedido FROM rol_cajero;
REVOKE INSERT, UPDATE, DELETE ON restaurante.detalle_pedido FROM rol_cajero;

-- ===== rol_mesero: OPERADOR en su área =====
GRANT SELECT, INSERT, UPDATE ON restaurante.pedido TO rol_mesero;
GRANT SELECT, INSERT, UPDATE ON restaurante.detalle_pedido TO rol_mesero;
GRANT SELECT ON restaurante.mesa TO rol_mesero;
GRANT SELECT ON restaurante.plato TO rol_mesero;
GRANT SELECT, INSERT ON restaurante.cliente TO rol_mesero;

REVOKE DELETE ON restaurante.pedido FROM rol_mesero;
REVOKE DELETE ON restaurante.detalle_pedido FROM rol_mesero;

GRANT USAGE ON SCHEMA restaurante TO rol_cajero, rol_mesero;
-- NUEVA LÍNEA: rol_mesero necesita leer id/nombre de empleado
-- para que la política de RLS de P1d pueda identificar
-- "cuál es mi propio registro de empleado"
GRANT SELECT (id, nombre) ON restaurante.empleado TO rol_mesero;
-- ----------------------------------------------------------
-- P1c — GRANT por columna sobre 'empleado' (excluye 'salario')
-- ----------------------------------------------------------

-- rol_cajero puede ver los datos del empleado para identificar
-- quién atendió, pero NO debe ver cuánto gana (dato sensible/laboral).
GRANT SELECT (id, nombre, puesto, fecha_contratacion)
ON restaurante.empleado
TO rol_cajero;

-- Nota: no otorgamos SELECT sobre la columna 'salario' a propósito.
-- Si rol_cajero intenta: SELECT salario FROM restaurante.empleado;
-- PostgreSQL debe devolver: ERROR: permission denied for column salario

SELECT grantee, column_name, privilege_type
FROM information_schema.column_privileges
WHERE table_schema = 'restaurante'
  AND table_name = 'empleado'
  AND grantee = 'rol_cajero'
ORDER BY column_name;

-- ----------------------------------------------------------
-- P1d — Row Level Security sobre 'pedido'
-- ----------------------------------------------------------

-- Activamos RLS y forzamos que aplique incluso al dueño de la tabla
ALTER TABLE restaurante.pedido ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurante.pedido FORCE ROW LEVEL SECURITY;

-- Política FOR SELECT: cada mesero ve solo los pedidos donde
-- el empleado_id corresponde a su propio usuario de conexión.
-- Usamos CURRENT_USER comparado contra el nombre del empleado
-- vía un mapeo simple basado en el nombre del rol de login.
CREATE POLICY pedido_select_mesero
ON restaurante.pedido
FOR SELECT
TO rol_mesero
USING (
    empleado_id = (
        SELECT id FROM restaurante.empleado
        WHERE nombre = current_setting('app.mesero_actual', true)
    )
);

-- Política FOR INSERT: el mesero solo puede insertar pedidos
-- donde el empleado_id sea el suyo (no puede crear pedidos a nombre de otro)
CREATE POLICY pedido_insert_mesero
ON restaurante.pedido
FOR INSERT
TO rol_mesero
WITH CHECK (
    empleado_id = (
        SELECT id FROM restaurante.empleado
        WHERE nombre = current_setting('app.mesero_actual', true)
    )
);

SELECT * FROM pg_policies WHERE schemaname = 'restaurante';

-- ----------------------------------------------------------
-- P1d — Prueba de RLS con 2 sesiones simuladas (2 meseros)
-- ----------------------------------------------------------

-- ===== SESIÓN 1: Marco Antonio Diaz =====
SET ROLE rol_mesero;
SET app.mesero_actual = 'Marco Antonio Diaz';

SELECT id, mesa_id, estado, fecha_hora
FROM restaurante.pedido;
-- Esperado: solo los pedidos atendidos por Marco Antonio Diaz

-- ===== SESIÓN 2: Sofía Elena Quesada (mismo rol, distinto mesero) =====
SET app.mesero_actual = 'Sofia Elena Quesada';

SELECT id, mesa_id, estado, fecha_hora
FROM restaurante.pedido;
-- Esperado: un conjunto DISTINTO de pedidos, atendidos por Sofía

-- ===== Volvemos a nuestro rol original (superusuario) =====
RESET ROLE;
RESET app.mesero_actual;