-- ============================================================
-- ISW-522 - Quiz 1 Grupal - Sistema: Restaurante
-- BD: restaurantcr | Esquema: restaurante
-- Script: datos de prueba (10-15 filas por tabla)
-- Persona A
--
-- IMPORTANTE: ejecutar SOLO despues de que 00_schema_ddl.sql
-- haya corrido sin errores y las 8 tablas ya existan.
-- ============================================================

-- ----------------------------------------------------------
-- NIVEL 1: cliente, mesa, categoria_menu, empleado
-- (no dependen de nadie, se insertan primero)
-- ----------------------------------------------------------

INSERT INTO restaurante.cliente (nombre, telefono, correo) VALUES
('Maria Fernandez Solano', '8888-1234', 'maria.fernandez@example.com'),
('Carlos Ramirez Vargas', '8777-2345', 'carlos.ramirez@example.com'),
('Ana Lucia Mora', '8666-3456', 'ana.mora@example.com'),
('Jose Pablo Castro', '8555-4567', 'jose.castro@example.com'),
('Daniela Vega Rojas', '8444-5678', 'daniela.vega@example.com'),
('Luis Fernando Chaves', '8333-6789', 'luis.chaves@example.com'),
('Karla Patricia Solis', '8222-7890', NULL),
('Esteban Gomez Araya', '8111-8901', 'esteban.gomez@example.com'),
('Paola Jimenez Cruz', '7999-9012', 'paola.jimenez@example.com'),
('Ricardo Salas Mata', '7888-0123', 'ricardo.salas@example.com'),
('Fiorella Brenes Quiros', '7777-1234', 'fiorella.brenes@example.com'),
('Andres Villalobos Soto', '7666-2345', NULL);

INSERT INTO restaurante.mesa (numero, capacidad, ubicacion) VALUES
(1, 2, 'terraza'),
(2, 2, 'terraza'),
(3, 4, 'salon_principal'),
(4, 4, 'salon_principal'),
(5, 4, 'salon_principal'),
(6, 6, 'salon_principal'),
(7, 6, 'salon_principal'),
(8, 8, 'salon_vip'),
(9, 2, 'barra'),
(10, 2, 'barra'),
(11, 10, 'salon_vip'),
(12, 4, 'terraza');

INSERT INTO restaurante.categoria_menu (nombre, descripcion) VALUES
('entradas', 'Platos pequenos para abrir el apetito'),
('platos_fuertes', 'Platos principales del menu'),
('postres', 'Opciones dulces para cerrar la comida'),
('bebidas', 'Bebidas frias y calientes, con y sin alcohol');

INSERT INTO restaurante.empleado (nombre, puesto, salario, fecha_contratacion) VALUES
('Marco Antonio Diaz', 'mesero', 380000.00, '2022-03-15'),
('Sofia Elena Quesada', 'mesero', 380000.00, '2022-06-01'),
('Roberto Carlos Pena', 'mesero', 400000.00, '2021-11-10'),
('Vanessa Maria Lopez', 'cajero', 420000.00, '2023-01-20'),
('Diego Alonso Rojas', 'cajero', 420000.00, '2023-04-05'),
('Gabriela Isabel Mora', 'cocinero', 450000.00, '2020-09-12'),
('Fernando Jose Araya', 'cocinero', 450000.00, '2021-02-28'),
('Natalia Beatriz Ruiz', 'cocinero', 470000.00, '2019-07-19'),
('Kevin Stuart Brenes', 'administrador', 650000.00, '2018-05-01'),
('Laura Patricia Sanchez', 'mesero', 380000.00, '2023-08-14');

-- ----------------------------------------------------------
-- NIVEL 2: plato
-- depende de categoria_menu, se resuelve el FK por subconsulta
-- ----------------------------------------------------------

INSERT INTO restaurante.plato (categoria_id, nombre, precio, disponible, ingredientes) VALUES
((SELECT id FROM restaurante.categoria_menu WHERE nombre = 'entradas'),
    'Ceviche de pescado', 4500.00, TRUE,
    '{"ingredientes": ["pescado", "limon", "cebolla", "culantro", "chile"], "alergenos": ["pescado"]}'),
((SELECT id FROM restaurante.categoria_menu WHERE nombre = 'entradas'),
    'Patacones con frijoles', 3200.00, TRUE,
    '{"ingredientes": ["platano verde", "frijoles", "queso"], "alergenos": ["lacteos"]}'),
((SELECT id FROM restaurante.categoria_menu WHERE nombre = 'entradas'),
    'Sopa negra', 2800.00, TRUE,
    '{"ingredientes": ["frijoles negros", "huevo", "cebolla", "culantro"], "alergenos": ["huevo"]}'),
((SELECT id FROM restaurante.categoria_menu WHERE nombre = 'platos_fuertes'),
    'Casado con pollo', 5200.00, TRUE,
    '{"ingredientes": ["arroz", "frijoles", "pollo", "ensalada", "platano maduro"], "alergenos": []}'),
((SELECT id FROM restaurante.categoria_menu WHERE nombre = 'platos_fuertes'),
    'Casado con res', 5800.00, TRUE,
    '{"ingredientes": ["arroz", "frijoles", "res", "ensalada", "platano maduro"], "alergenos": []}'),
((SELECT id FROM restaurante.categoria_menu WHERE nombre = 'platos_fuertes'),
    'Arroz con camarones', 6500.00, TRUE,
    '{"ingredientes": ["arroz", "camaron", "vegetales", "salsa de soya"], "alergenos": ["mariscos", "soya"]}'),
((SELECT id FROM restaurante.categoria_menu WHERE nombre = 'platos_fuertes'),
    'Olla de carne', 6200.00, FALSE,
    '{"ingredientes": ["res", "yuca", "elote", "platano", "ayote"], "alergenos": []}'),
((SELECT id FROM restaurante.categoria_menu WHERE nombre = 'postres'),
    'Tres leches', 2200.00, TRUE,
    '{"ingredientes": ["leche", "huevo", "azucar", "harina"], "alergenos": ["lacteos", "huevo", "gluten"]}'),
((SELECT id FROM restaurante.categoria_menu WHERE nombre = 'postres'),
    'Flan de coco', 2000.00, TRUE,
    '{"ingredientes": ["coco", "leche condensada", "huevo"], "alergenos": ["lacteos", "huevo"]}'),
((SELECT id FROM restaurante.categoria_menu WHERE nombre = 'bebidas'),
    'Fresco de cas', 1200.00, TRUE,
    '{"ingredientes": ["cas", "azucar", "agua"], "alergenos": []}'),
((SELECT id FROM restaurante.categoria_menu WHERE nombre = 'bebidas'),
    'Cafe negro', 900.00, TRUE,
    '{"ingredientes": ["cafe"], "alergenos": []}'),
((SELECT id FROM restaurante.categoria_menu WHERE nombre = 'bebidas'),
    'Cerveza artesanal', 2500.00, TRUE,
    '{"ingredientes": ["cebada", "lupulo", "levadura", "agua"], "alergenos": ["gluten"]}');

-- ----------------------------------------------------------
-- NIVEL 3: pedido
-- depende de mesa, cliente y empleado
-- ----------------------------------------------------------

INSERT INTO restaurante.pedido (mesa_id, cliente_id, empleado_id, estado, fecha_hora, notas_personalizacion) VALUES
((SELECT id FROM restaurante.mesa WHERE numero = 1),
    (SELECT id FROM restaurante.cliente WHERE nombre = 'Maria Fernandez Solano'),
    (SELECT id FROM restaurante.empleado WHERE nombre = 'Marco Antonio Diaz'),
    'pagado', '2026-06-10 12:30:00', '{"alergias": "ninguna"}'),
((SELECT id FROM restaurante.mesa WHERE numero = 3),
    (SELECT id FROM restaurante.cliente WHERE nombre = 'Carlos Ramirez Vargas'),
    (SELECT id FROM restaurante.empleado WHERE nombre = 'Sofia Elena Quesada'),
    'pagado', '2026-06-10 13:00:00', '{"alergias": "mariscos"}'),
((SELECT id FROM restaurante.mesa WHERE numero = 4),
    (SELECT id FROM restaurante.cliente WHERE nombre = 'Ana Lucia Mora'),
    (SELECT id FROM restaurante.empleado WHERE nombre = 'Sofia Elena Quesada'),
    'servido', '2026-06-10 13:15:00', NULL),
((SELECT id FROM restaurante.mesa WHERE numero = 6),
    (SELECT id FROM restaurante.cliente WHERE nombre = 'Jose Pablo Castro'),
    (SELECT id FROM restaurante.empleado WHERE nombre = 'Roberto Carlos Pena'),
    'pagado', '2026-06-11 19:00:00', '{"ocasion": "cumpleanos"}'),
((SELECT id FROM restaurante.mesa WHERE numero = 8),
    (SELECT id FROM restaurante.cliente WHERE nombre = 'Daniela Vega Rojas'),
    (SELECT id FROM restaurante.empleado WHERE nombre = 'Marco Antonio Diaz'),
    'pagado', '2026-06-11 19:30:00', NULL),
((SELECT id FROM restaurante.mesa WHERE numero = 2),
    (SELECT id FROM restaurante.cliente WHERE nombre = 'Luis Fernando Chaves'),
    (SELECT id FROM restaurante.empleado WHERE nombre = 'Roberto Carlos Pena'),
    'en_preparacion', '2026-06-12 12:45:00', NULL),
((SELECT id FROM restaurante.mesa WHERE numero = 5),
    (SELECT id FROM restaurante.cliente WHERE nombre = 'Karla Patricia Solis'),
    (SELECT id FROM restaurante.empleado WHERE nombre = 'Sofia Elena Quesada'),
    'pendiente', '2026-06-12 13:00:00', '{"alergias": "lacteos"}'),
((SELECT id FROM restaurante.mesa WHERE numero = 7),
    (SELECT id FROM restaurante.cliente WHERE nombre = 'Esteban Gomez Araya'),
    (SELECT id FROM restaurante.empleado WHERE nombre = 'Marco Antonio Diaz'),
    'pagado', '2026-06-12 20:00:00', NULL),
((SELECT id FROM restaurante.mesa WHERE numero = 9),
    (SELECT id FROM restaurante.cliente WHERE nombre = 'Paola Jimenez Cruz'),
    (SELECT id FROM restaurante.empleado WHERE nombre = 'Roberto Carlos Pena'),
    'pagado', '2026-06-13 18:30:00', NULL),
((SELECT id FROM restaurante.mesa WHERE numero = 11),
    (SELECT id FROM restaurante.cliente WHERE nombre = 'Ricardo Salas Mata'),
    (SELECT id FROM restaurante.empleado WHERE nombre = 'Laura Patricia Sanchez'),
    'pagado', '2026-06-13 19:45:00', '{"ocasion": "reunion_empresarial"}'),
((SELECT id FROM restaurante.mesa WHERE numero = 4),
    (SELECT id FROM restaurante.cliente WHERE nombre = 'Fiorella Brenes Quiros'),
    (SELECT id FROM restaurante.empleado WHERE nombre = 'Laura Patricia Sanchez'),
    'cancelado', '2026-06-14 12:00:00', NULL),
((SELECT id FROM restaurante.mesa WHERE numero = 10),
    (SELECT id FROM restaurante.cliente WHERE nombre = 'Andres Villalobos Soto'),
    (SELECT id FROM restaurante.empleado WHERE nombre = 'Marco Antonio Diaz'),
    'servido', '2026-06-14 13:30:00', NULL);

-- ----------------------------------------------------------
-- NIVEL 4: detalle_pedido y pago
-- dependen de pedido (y detalle_pedido tambien de plato)
-- ----------------------------------------------------------

-- Pedido 1: Maria Fernandez, mesa 1
INSERT INTO restaurante.detalle_pedido (pedido_id, plato_id, cantidad, notas) VALUES
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Maria Fernandez Solano') AND fecha_hora = '2026-06-10 12:30:00'),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Ceviche de pescado'), 1, NULL),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Maria Fernandez Solano') AND fecha_hora = '2026-06-10 12:30:00'),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Fresco de cas'), 1, 'sin azucar');

-- Pedido 2: Carlos Ramirez, mesa 3
INSERT INTO restaurante.detalle_pedido (pedido_id, plato_id, cantidad, notas) VALUES
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Carlos Ramirez Vargas')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Casado con pollo'), 2, NULL),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Carlos Ramirez Vargas')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Cafe negro'), 2, NULL);

-- Pedido 3: Ana Lucia Mora, mesa 4
INSERT INTO restaurante.detalle_pedido (pedido_id, plato_id, cantidad, notas) VALUES
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Ana Lucia Mora')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Arroz con camarones'), 1, 'extra picante');

-- Pedido 4: Jose Pablo Castro, mesa 6 (cumpleanos)
INSERT INTO restaurante.detalle_pedido (pedido_id, plato_id, cantidad, notas) VALUES
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Jose Pablo Castro')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Casado con res'), 3, NULL),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Jose Pablo Castro')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Tres leches'), 1, 'con vela'),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Jose Pablo Castro')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Cerveza artesanal'), 2, NULL);

-- Pedido 5: Daniela Vega, mesa 8
INSERT INTO restaurante.detalle_pedido (pedido_id, plato_id, cantidad, notas) VALUES
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Daniela Vega Rojas')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Patacones con frijoles'), 1, NULL),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Daniela Vega Rojas')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Casado con pollo'), 1, NULL),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Daniela Vega Rojas')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Flan de coco'), 1, NULL);

-- Pedido 6: Luis Fernando Chaves, mesa 2 (en preparacion)
INSERT INTO restaurante.detalle_pedido (pedido_id, plato_id, cantidad, notas) VALUES
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Luis Fernando Chaves')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Sopa negra'), 1, 'sin huevo');

-- Pedido 7: Karla Patricia Solis, mesa 5 (pendiente)
INSERT INTO restaurante.detalle_pedido (pedido_id, plato_id, cantidad, notas) VALUES
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Karla Patricia Solis')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Casado con res'), 1, 'sin queso');

-- Pedido 8: Esteban Gomez, mesa 7
INSERT INTO restaurante.detalle_pedido (pedido_id, plato_id, cantidad, notas) VALUES
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Esteban Gomez Araya')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Olla de carne'), 1, NULL),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Esteban Gomez Araya')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Cerveza artesanal'), 3, NULL);

-- Pedido 9: Paola Jimenez, mesa 9
INSERT INTO restaurante.detalle_pedido (pedido_id, plato_id, cantidad, notas) VALUES
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Paola Jimenez Cruz')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Ceviche de pescado'), 1, NULL),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Paola Jimenez Cruz')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Fresco de cas'), 1, NULL);

-- Pedido 10: Ricardo Salas, mesa 11 (reunion empresarial)
INSERT INTO restaurante.detalle_pedido (pedido_id, plato_id, cantidad, notas) VALUES
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Ricardo Salas Mata')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Casado con res'), 4, NULL),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Ricardo Salas Mata')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Arroz con camarones'), 2, NULL),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Ricardo Salas Mata')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Cafe negro'), 6, NULL);

-- Pedido 11: Fiorella Brenes (cancelado, sin detalle ni pago)

-- Pedido 12: Andres Villalobos, mesa 10
INSERT INTO restaurante.detalle_pedido (pedido_id, plato_id, cantidad, notas) VALUES
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Andres Villalobos Soto')),
    (SELECT id FROM restaurante.plato WHERE nombre = 'Patacones con frijoles'), 1, NULL);

-- ----------------------------------------------------------
-- pago: solo para pedidos que llegaron a estado 'pagado'
-- (el pedido cancelado y los que aun no terminan, no tienen pago)
-- ----------------------------------------------------------

INSERT INTO restaurante.pago (pedido_id, monto, metodo, propina, fecha_pago) VALUES
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Maria Fernandez Solano')),
    5700.00, 'tarjeta', 600.00, '2026-06-10 13:10:00'),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Carlos Ramirez Vargas')),
    11200.00, 'sinpe_movil', 1000.00, '2026-06-10 13:45:00'),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Jose Pablo Castro')),
    24700.00, 'tarjeta', 2500.00, '2026-06-11 20:15:00'),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Daniela Vega Rojas')),
    9400.00, 'efectivo', 800.00, '2026-06-11 20:30:00'),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Esteban Gomez Araya')),
    13700.00, 'tarjeta', 1500.00, '2026-06-12 21:00:00'),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Paola Jimenez Cruz')),
    5700.00, 'sinpe_movil', 500.00, '2026-06-13 19:15:00'),
((SELECT id FROM restaurante.pedido WHERE cliente_id = (SELECT id FROM restaurante.cliente WHERE nombre = 'Ricardo Salas Mata')),
    42600.00, 'tarjeta', 4500.00, '2026-06-13 20:30:00');





-----------------------------------------------------------------
Ejecuta esto en el Query Tool para confirmar que todo entró bien:
-----------------------------------------------------------------

SELECT 'cliente' AS tabla, COUNT(*) FROM restaurante.cliente
UNION ALL SELECT 'mesa', COUNT(*) FROM restaurante.mesa
UNION ALL SELECT 'categoria_menu', COUNT(*) FROM restaurante.categoria_menu
UNION ALL SELECT 'empleado', COUNT(*) FROM restaurante.empleado
UNION ALL SELECT 'plato', COUNT(*) FROM restaurante.plato
UNION ALL SELECT 'pedido', COUNT(*) FROM restaurante.pedido
UNION ALL SELECT 'detalle_pedido', COUNT(*) FROM restaurante.detalle_pedido
UNION ALL SELECT 'pago', COUNT(*) FROM restaurante.pago;