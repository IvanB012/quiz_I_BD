-- Archivo: 04_indices.sql
-- P4 - Indices Estrategicos y Analisis de Rendimiento
-- Persona B (con un indice adicional aportado por Persona A para P2b-ii)
-- ----------------------------------------------------------
-- P4a - Consultas candidatas a indice (documentado en comentarios)
-- ----------------------------------------------------------
-- Consulta 1: pedidos por rango de fecha_hora
--   Caso de uso: cierre de caja diario, reportes por turno
--   Scan esperado sin indice: Seq Scan
--
-- Consulta 2: pedidos por estado = 'pendiente'
--   Caso de uso: cocina/meseros revisan pedidos aun no atendidos
--   Scan esperado sin indice: Seq Scan
--
-- Consulta 3: detalle_pedido por plato_id
--   Caso de uso: reportes de ventas por plato (ranking, ingresos)
--   Scan esperado sin indice: Seq Scan
--
-- Consulta 4: platos que contienen cierto alergeno dentro de ingredientes (JSONB)
--   Caso de uso: filtrar el menu por alergeno para un cliente con restricciones
--   Scan esperado sin indice: Seq Scan
-- ----------------------------------------------------------
-- P4b - Generacion de volumen con generate_series()
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

-- ----- EXPLAIN ANALYZE "ANTES" (sin indices) -----
-- (Para esta medicion se eliminaron temporalmente los indices
-- de abajo y se volvieron a crear despues; ver tabla comparativa
-- de P4d al final del archivo)

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM restaurante.pedido
WHERE fecha_hora >= '2026-06-10' AND fecha_hora < '2026-06-13';
-- SIN indice: Seq Scan on pedido, Execution Time: 2.400 ms

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM restaurante.pedido
WHERE estado = 'pendiente';
-- SIN indice: Seq Scan on pedido, Execution Time: 0.042 ms

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM restaurante.detalle_pedido
WHERE plato_id = (SELECT id FROM restaurante.plato WHERE nombre = 'Casado con res');
-- SIN indice: Seq Scan on detalle_pedido, Execution Time: 2.420 ms

EXPLAIN (ANALYZE, BUFFERS)
SELECT nombre FROM restaurante.plato
WHERE ingredientes @> '{"alergenos": ["lacteos"]}';
-- SIN indice: Seq Scan on plato, Execution Time: 0.038 ms

-- ----------------------------------------------------------
-- P4c - Creacion de indices estrategicos
-- ----------------------------------------------------------

-- Indice 1: B-Tree simple sobre pedido.fecha_hora
CREATE INDEX idx_pedido_fecha_hora
ON restaurante.pedido (fecha_hora);

-- Indice 2: Indice PARCIAL sobre pedido.estado
CREATE INDEX idx_pedido_pendientes
ON restaurante.pedido (estado)
WHERE estado = 'pendiente';

-- Indice 3: B-Tree sobre detalle_pedido.plato_id
CREATE INDEX idx_detalle_plato_id
ON restaurante.detalle_pedido (plato_id);

-- Indice 4: GIN sobre plato.ingredientes (justificado en P2b-ii, JSONB)
-- Permite buscar eficientemente DENTRO de la estructura JSON,
-- por ejemplo encontrar platos por alergeno o por ingrediente especifico.
CREATE INDEX idx_plato_ingredientes_gin
ON restaurante.plato
USING GIN (ingredientes);

-- Actualizamos estadisticas para que el planificador las use
ANALYZE restaurante.pedido;
ANALYZE restaurante.detalle_pedido;
ANALYZE restaurante.plato;

-- ----- Verificacion del indice GIN (Method = GIN) -----
-- Confirmado en pgAdmin: restaurante > Tables > plato > Indexes >
-- idx_plato_ingredientes_gin > Definition > Access Method = gin
-- Tambien verificable por SQL:
SELECT indexname, tablename, indexdef
FROM pg_indexes
WHERE schemaname = 'restaurante'
ORDER BY tablename, indexname;

-- ----- EXPLAIN ANALYZE "DESPUES" (con indices) -----

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM restaurante.pedido
WHERE fecha_hora >= '2026-06-10' AND fecha_hora < '2026-06-13';
-- CON indice: Seq Scan on pedido (SIN CAMBIO), Execution Time: 0.051 ms
-- Nota P4d: el planificador ignora el indice porque la tabla pedido
-- es muy pequena (12 filas); un Seq Scan completo es mas rapido
-- que usar el indice en tablas de este tamano.

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM restaurante.pedido
WHERE estado = 'pendiente';
-- CON indice: Seq Scan on pedido (SIN CAMBIO), Execution Time: 0.049 ms
-- Misma razon que el caso anterior: tabla demasiado pequena.

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM restaurante.detalle_pedido
WHERE plato_id = (SELECT id FROM restaurante.plato WHERE nombre = 'Casado con res');
-- CON indice: Bitmap Heap Scan + Bitmap Index Scan on idx_detalle_plato_id
-- Execution Time: 0.720 ms
-- Aqui si se uso el indice: detalle_pedido tiene 5000+ filas.

EXPLAIN (ANALYZE, BUFFERS)
SELECT nombre FROM restaurante.plato
WHERE ingredientes @> '{"alergenos": ["lacteos"]}';
-- CON indice: revisar si aparece Bitmap Heap Scan + Bitmap Index Scan
-- on idx_plato_ingredientes_gin, o si por ser una tabla pequena (12 filas)
-- el planificador tambien decide usar Seq Scan (documentar el resultado real).
