
-- Archivo: 04_indices.sql
-- P4 - Índices Estratégicos y Análisis de Rendimiento


-- ----------------------------------------------------------
-- P4a — Consultas candidatas a índice (documentado en comentarios)
-- ----------------------------------------------------------
-- Consulta 1: pedidos por rango de fecha_hora
--   Caso de uso: cierre de caja diario, reportes por turno
--   Scan esperado sin índice: Seq Scan
--
-- Consulta 2: pedidos por estado = 'pendiente'
--   Caso de uso: cocina/meseros revisan pedidos aún no atendidos
--   Scan esperado sin índice: Seq Scan
--
-- Consulta 3: detalle_pedido por plato_id
--   Caso de uso: reportes de ventas por plato (ranking, ingresos)
--   Scan esperado sin índice: Seq Scan

-- ----------------------------------------------------------
-- P4b — Generación de volumen con generate_series()
-- ----------------------------------------------------------
INSERT INTO restaurante.detalle_pedido (pedido_id, plato_id, cantidad, notas)
SELECT
    (SELECT id FROM restaurante.pedido ORDER BY id OFFSET (s % 12) LIMIT 1),
    (SELECT id FROM restaurante.plato ORDER BY id OFFSET (s % 12) LIMIT 1),
    (1 + (s % 5)),
    NULL
FROM generate_series(1, 5000) AS s;

SELECT COUNT(*) FROM restaurante.detalle_pedido;
-- Resultado: 5021 filas

-- ----- EXPLAIN ANALYZE "ANTES" (sin índices) -----
-- (Para esta medición se eliminaron temporalmente los índices
-- de abajo y se volvieron a crear después; ver tabla comparativa
-- de P4d al final del archivo)

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM restaurante.pedido
WHERE fecha_hora >= '2026-06-10' AND fecha_hora < '2026-06-13';
-- SIN índice: Seq Scan on pedido, Execution Time: 2.400 ms

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM restaurante.pedido
WHERE estado = 'pendiente';
-- SIN índice: Seq Scan on pedido, Execution Time: 0.042 ms

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM restaurante.detalle_pedido
WHERE plato_id = (SELECT id FROM restaurante.plato WHERE nombre = 'Casado con res');
-- SIN índice: Seq Scan on detalle_pedido, Execution Time: 2.420 ms

-- ----------------------------------------------------------
-- P4c — Creación de índices estratégicos
-- ----------------------------------------------------------

-- Índice 1: B-Tree simple sobre pedido.fecha_hora
CREATE INDEX idx_pedido_fecha_hora
ON restaurante.pedido (fecha_hora);

-- Índice 2: Índice PARCIAL sobre pedido.estado
CREATE INDEX idx_pedido_pendientes
ON restaurante.pedido (estado)
WHERE estado = 'pendiente';

-- Índice 3: B-Tree sobre detalle_pedido.plato_id
CREATE INDEX idx_detalle_plato_id
ON restaurante.detalle_pedido (plato_id);

-- Actualizamos estadísticas para que el planificador las use
ANALYZE restaurante.pedido;
ANALYZE restaurante.detalle_pedido;

-- ----- EXPLAIN ANALYZE "DESPUÉS" (con índices) -----

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM restaurante.pedido
WHERE fecha_hora >= '2026-06-10' AND fecha_hora < '2026-06-13';
-- CON índice: Seq Scan on pedido (SIN CAMBIO), Execution Time: 0.051 ms

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM restaurante.pedido
WHERE estado = 'pendiente';
-- CON índice: Seq Scan on pedido (SIN CAMBIO), Execution Time: 0.049 ms

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM restaurante.detalle_pedido
WHERE plato_id = (SELECT id FROM restaurante.plato WHERE nombre = 'Casado con res');
-- CON índice: Bitmap Heap Scan + Bitmap Index Scan on idx_detalle_plato_id
-- Execution Time: 0.720 ms

