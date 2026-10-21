-- =====================================================================
-- ENTREGABLE PARCIAL - Data Analytics para los Negocios
-- Archivo 2: Consultas SQL
-- Caso de negocio: Cafetería "Aroma Andino" (ventas de productos)
-- Autora: Daniela Miranda Vizcarra
-- Motor: PostgreSQL (Supabase)
-- Nota: ejecutar primero 01_creacion_tablas_cafeteria.sql
-- =====================================================================

-- ---------------------------------------------------------------------
-- A. CONSULTAS SELECT BÁSICAS
-- ---------------------------------------------------------------------

-- 1. Productos con precio mayor a S/ 9.00, del más caro al más barato
SELECT nombre, precio, stock
FROM productos
WHERE precio > 9.00
ORDER BY precio DESC;

-- 2. Pedidos que aún están pendientes de entrega
SELECT id_pedido, id_cliente, fecha_pedido, metodo_pago
FROM pedidos
WHERE estado = 'Pendiente';

-- ---------------------------------------------------------------------
-- B. CONSULTAS CON JOIN
-- ---------------------------------------------------------------------

-- 3. Lista de productos con el nombre de su categoría (INNER JOIN)
SELECT p.nombre AS producto,
       c.nombre AS categoria,
       p.precio
FROM productos p
INNER JOIN categorias c ON c.id_categoria = p.id_categoria
ORDER BY c.nombre, p.nombre;

-- 4. Detalle completo de ventas: cliente, producto y subtotal (4 tablas)
SELECT pe.id_pedido,
       cl.nombre || ' ' || cl.apellido AS cliente,
       pr.nombre AS producto,
       d.cantidad,
       d.precio_unitario,
       d.cantidad * d.precio_unitario AS subtotal
FROM detalle_pedidos d
INNER JOIN pedidos   pe ON pe.id_pedido   = d.id_pedido
INNER JOIN clientes  cl ON cl.id_cliente  = pe.id_cliente
INNER JOIN productos pr ON pr.id_producto = d.id_producto
ORDER BY pe.id_pedido, pr.nombre;

-- ---------------------------------------------------------------------
-- C. FUNCIONES DE AGREGACIÓN (COUNT, SUM, AVG, MAX, MIN) CON JOIN
-- ---------------------------------------------------------------------

-- 5. COUNT: cantidad de productos por categoría (LEFT JOIN incluye categorías vacías)
SELECT c.nombre AS categoria,
       COUNT(p.id_producto) AS total_productos
FROM categorias c
LEFT JOIN productos p ON p.id_categoria = c.id_categoria
GROUP BY c.nombre
ORDER BY total_productos DESC;

-- 6. AVG, MAX y MIN: precio promedio, más alto y más bajo por categoría
SELECT c.nombre AS categoria,
       ROUND(AVG(p.precio), 2) AS precio_promedio,
       MAX(p.precio)           AS precio_maximo,
       MIN(p.precio)           AS precio_minimo
FROM productos p
INNER JOIN categorias c ON c.id_categoria = p.id_categoria
GROUP BY c.nombre
ORDER BY precio_promedio DESC;

-- 7. SUM: total de cada pedido, con el nombre del cliente
SELECT pe.id_pedido,
       cl.nombre || ' ' || cl.apellido AS cliente,
       pe.fecha_pedido,
       SUM(d.cantidad * d.precio_unitario) AS total_pedido
FROM pedidos pe
INNER JOIN clientes        cl ON cl.id_cliente = pe.id_cliente
INNER JOIN detalle_pedidos d  ON d.id_pedido   = pe.id_pedido
GROUP BY pe.id_pedido, cl.nombre, cl.apellido, pe.fecha_pedido
ORDER BY pe.id_pedido;

-- 8. SUM: productos más vendidos (unidades e ingresos generados)
SELECT pr.nombre AS producto,
       SUM(d.cantidad)                     AS unidades_vendidas,
       SUM(d.cantidad * d.precio_unitario) AS ingresos
FROM detalle_pedidos d
INNER JOIN productos pr ON pr.id_producto = d.id_producto
GROUP BY pr.nombre
ORDER BY unidades_vendidas DESC, ingresos DESC;

-- 9. SUM + HAVING: clientes que han gastado más de S/ 40 en total
SELECT cl.nombre || ' ' || cl.apellido AS cliente,
       COUNT(DISTINCT pe.id_pedido)    AS pedidos_realizados,
       SUM(d.cantidad * d.precio_unitario) AS total_gastado
FROM clientes cl
INNER JOIN pedidos         pe ON pe.id_cliente = cl.id_cliente
INNER JOIN detalle_pedidos d  ON d.id_pedido   = pe.id_pedido
GROUP BY cl.id_cliente, cl.nombre, cl.apellido
HAVING SUM(d.cantidad * d.precio_unitario) > 40
ORDER BY total_gastado DESC;

-- 10. COUNT + SUM: ventas según el método de pago
SELECT pe.metodo_pago,
       COUNT(DISTINCT pe.id_pedido)        AS num_pedidos,
       SUM(d.cantidad * d.precio_unitario) AS total_vendido
FROM pedidos pe
INNER JOIN detalle_pedidos d ON d.id_pedido = pe.id_pedido
GROUP BY pe.metodo_pago
ORDER BY total_vendido DESC;

-- 11. SUM + AVG: ventas por mes y ticket promedio por pedido
SELECT TO_CHAR(pe.fecha_pedido, 'YYYY-MM') AS mes,
       COUNT(DISTINCT pe.id_pedido)        AS num_pedidos,
       SUM(d.cantidad * d.precio_unitario) AS total_vendido,
       ROUND(SUM(d.cantidad * d.precio_unitario)
             / COUNT(DISTINCT pe.id_pedido), 2) AS ticket_promedio
FROM pedidos pe
INNER JOIN detalle_pedidos d ON d.id_pedido = pe.id_pedido
GROUP BY TO_CHAR(pe.fecha_pedido, 'YYYY-MM')
ORDER BY mes;

-- ---------------------------------------------------------------------
-- D. CONSULTAS DE ANÁLISIS PARA EL NEGOCIO (LEFT JOIN + IS NULL)
-- ---------------------------------------------------------------------

-- 12. Productos que nunca se han vendido
SELECT p.nombre, p.precio, p.stock
FROM productos p
LEFT JOIN detalle_pedidos d ON d.id_producto = p.id_producto
WHERE d.id_detalle IS NULL;

-- 13. Clientes registrados que todavía no han hecho ningún pedido
SELECT cl.nombre, cl.apellido, cl.correo
FROM clientes cl
LEFT JOIN pedidos pe ON pe.id_cliente = cl.id_cliente
WHERE pe.id_pedido IS NULL;
