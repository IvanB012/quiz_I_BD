
-- Archivo: 03_consultas.sql
-- P3a - JOIN de 3+ tablas con agregación



-- Pregunta de negocio: ¿qué mesero generó más ingresos por categoría
-- de plato, considerando solo categorías con más de 1 línea de detalle?
-- Devuelve: filas agrupadas por mesero y categoría, con total de platos
-- vendidos e ingreso total, ordenadas de mayor a menor ingreso.

SELECT
    e.nombre AS mesero,
    cm.nombre AS categoria,
    COUNT(dp.id) AS cantidad_platos_vendidos,
    SUM(dp.cantidad * p.precio) AS ingreso_total
FROM restaurante.pedido pe
JOIN restaurante.empleado e ON e.id = pe.empleado_id
JOIN restaurante.detalle_pedido dp ON dp.pedido_id = pe.id
JOIN restaurante.plato p ON p.id = dp.plato_id
JOIN restaurante.categoria_menu cm ON cm.id = p.categoria_id
GROUP BY e.nombre, cm.nombre
HAVING COUNT(dp.id) > 1
ORDER BY ingreso_total DESC;

-- ============================================================
-- P3b - Subconsulta correlacionada vs. JOIN equivalente
-- ============================================================

-- Pregunta de negocio: ¿qué clientes han gastado, en total, más que
-- el promedio general de gasto por cliente (considerando solo pagos)?

-- ----- VERSIÓN A: subconsulta correlacionada -----
-- La subconsulta interna referencia c.id (columna del SELECT externo)
SELECT
    c.nombre AS cliente,
    (SELECT SUM(pg.monto)
     FROM restaurante.pago pg
     JOIN restaurante.pedido pe ON pe.id = pg.pedido_id
     WHERE pe.cliente_id = c.id) AS total_gastado
FROM restaurante.cliente c
WHERE (SELECT SUM(pg.monto)
       FROM restaurante.pago pg
       JOIN restaurante.pedido pe ON pe.id = pg.pedido_id
       WHERE pe.cliente_id = c.id) > (
           SELECT AVG(total_por_cliente) FROM (
               SELECT SUM(pg2.monto) AS total_por_cliente
               FROM restaurante.pago pg2
               JOIN restaurante.pedido pe2 ON pe2.id = pg2.pedido_id
               GROUP BY pe2.cliente_id
           ) sub
       )
ORDER BY total_gastado DESC;

-- ----- VERSIÓN B: JOIN equivalente -----
WITH gasto_por_cliente AS (
    SELECT
        pe.cliente_id,
        SUM(pg.monto) AS total_gastado
    FROM restaurante.pago pg
    JOIN restaurante.pedido pe ON pe.id = pg.pedido_id
    GROUP BY pe.cliente_id
),
promedio_general AS (
    SELECT AVG(total_gastado) AS promedio FROM gasto_por_cliente
)
SELECT
    c.nombre AS cliente,
    gpc.total_gastado
FROM gasto_por_cliente gpc
JOIN restaurante.cliente c ON c.id = gpc.cliente_id
JOIN promedio_general pg ON gpc.total_gastado > pg.promedio
ORDER BY gpc.total_gastado DESC;

--EXPLAIN ANALYZE de ambas:
--1
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    c.nombre AS cliente,
    (SELECT SUM(pg.monto)
     FROM restaurante.pago pg
     JOIN restaurante.pedido pe ON pe.id = pg.pedido_id
     WHERE pe.cliente_id = c.id) AS total_gastado
FROM restaurante.cliente c
WHERE (SELECT SUM(pg.monto)
       FROM restaurante.pago pg
       JOIN restaurante.pedido pe ON pe.id = pg.pedido_id
       WHERE pe.cliente_id = c.id) > (
           SELECT AVG(total_por_cliente) FROM (
               SELECT SUM(pg2.monto) AS total_por_cliente
               FROM restaurante.pago pg2
               JOIN restaurante.pedido pe2 ON pe2.id = pg2.pedido_id
               GROUP BY pe2.cliente_id
           ) sub
       )
ORDER BY total_gastado DESC;
--2
EXPLAIN (ANALYZE, BUFFERS)
WITH gasto_por_cliente AS (
    SELECT
        pe.cliente_id,
        SUM(pg.monto) AS total_gastado
    FROM restaurante.pago pg
    JOIN restaurante.pedido pe ON pe.id = pg.pedido_id
    GROUP BY pe.cliente_id
),
promedio_general AS (
    SELECT AVG(total_gastado) AS promedio FROM gasto_por_cliente
)
SELECT
    c.nombre AS cliente,
    gpc.total_gastado
FROM gasto_por_cliente gpc
JOIN restaurante.cliente c ON c.id = gpc.cliente_id
JOIN promedio_general pg ON gpc.total_gastado > pg.promedio
ORDER BY gpc.total_gastado DESC;

-- ============================================================
-- P3c - CTE con Window Function
-- ============================================================
WITH ventas_por_plato AS (
    SELECT
        p.nombre AS plato,
        cm.nombre AS categoria,
        SUM(dp.cantidad) AS unidades_vendidas,
        SUM(dp.cantidad * p.precio) AS ingreso_total
    FROM restaurante.detalle_pedido dp
    JOIN restaurante.plato p ON p.id = dp.plato_id
    JOIN restaurante.categoria_menu cm ON cm.id = p.categoria_id
    GROUP BY p.nombre, cm.nombre
)
SELECT
    plato,
    categoria,
    unidades_vendidas,
    ingreso_total,
    RANK() OVER (ORDER BY unidades_vendidas DESC) AS ranking_ventas,
    SUM(ingreso_total) OVER (ORDER BY unidades_vendidas DESC) AS ingreso_acumulado
FROM ventas_por_plato
ORDER BY ranking_ventas
LIMIT 5;

