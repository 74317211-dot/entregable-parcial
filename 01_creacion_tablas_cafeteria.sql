-- =====================================================================
-- ENTREGABLE PARCIAL - Data Analytics para los Negocios
-- Archivo 1: Creación de tablas, relaciones y datos de ejemplo
-- Caso de negocio: Cafetería "Aroma Andino" (ventas de productos)
-- Autora: Daniela Miranda Vizcarra
-- Motor: PostgreSQL (Supabase)
-- =====================================================================

-- Limpieza (permite volver a ejecutar el script sin errores)
DROP TABLE IF EXISTS detalle_pedidos CASCADE;
DROP TABLE IF EXISTS pedidos         CASCADE;
DROP TABLE IF EXISTS productos       CASCADE;
DROP TABLE IF EXISTS clientes        CASCADE;
DROP TABLE IF EXISTS categorias      CASCADE;

-- ---------------------------------------------------------------------
-- 1. CREACIÓN DE TABLAS
-- ---------------------------------------------------------------------

-- Categorías de los productos (Bebidas, Postres, etc.)
CREATE TABLE categorias (
    id_categoria  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre        VARCHAR(50) NOT NULL UNIQUE
);

-- Productos que vende la cafetería (cada uno pertenece a una categoría)
CREATE TABLE productos (
    id_producto   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre        VARCHAR(80)  NOT NULL,
    id_categoria  BIGINT       NOT NULL REFERENCES categorias (id_categoria),
    precio        NUMERIC(8,2) NOT NULL CHECK (precio > 0),
    stock         INTEGER      NOT NULL DEFAULT 0 CHECK (stock >= 0)
);

-- Clientes registrados
CREATE TABLE clientes (
    id_cliente      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre          VARCHAR(60)  NOT NULL,
    apellido        VARCHAR(60)  NOT NULL,
    correo          VARCHAR(100) NOT NULL UNIQUE,
    telefono        VARCHAR(15),
    fecha_registro  DATE         NOT NULL DEFAULT CURRENT_DATE
);

-- Pedidos realizados (cada pedido pertenece a un cliente)
CREATE TABLE pedidos (
    id_pedido     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente    BIGINT      NOT NULL REFERENCES clientes (id_cliente),
    fecha_pedido  DATE        NOT NULL DEFAULT CURRENT_DATE,
    metodo_pago   VARCHAR(20) NOT NULL
                  CHECK (metodo_pago IN ('Efectivo', 'Tarjeta', 'Yape', 'Plin')),
    estado        VARCHAR(20) NOT NULL DEFAULT 'Pendiente'
                  CHECK (estado IN ('Pendiente', 'Entregado'))
);

-- Detalle de cada pedido (relaciona pedidos con productos: muchos a muchos)
CREATE TABLE detalle_pedidos (
    id_detalle       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pedido        BIGINT       NOT NULL REFERENCES pedidos (id_pedido) ON DELETE CASCADE,
    id_producto      BIGINT       NOT NULL REFERENCES productos (id_producto),
    cantidad         INTEGER      NOT NULL CHECK (cantidad > 0),
    precio_unitario  NUMERIC(8,2) NOT NULL CHECK (precio_unitario > 0)
);

-- ---------------------------------------------------------------------
-- 2. INSERCIÓN DE DATOS DE EJEMPLO
-- (Se insertan en este orden por las claves foráneas)
-- ---------------------------------------------------------------------

INSERT INTO categorias (nombre) VALUES
    ('Bebidas calientes'),   -- id 1
    ('Bebidas frías'),       -- id 2
    ('Postres'),             -- id 3
    ('Snacks');              -- id 4

INSERT INTO productos (nombre, id_categoria, precio, stock) VALUES
    ('Café Americano',          1,  6.50, 100),  -- id 1
    ('Capuchino',               1,  9.00,  80),  -- id 2
    ('Chocolate Caliente',      1,  8.50,  60),  -- id 3
    ('Frappé de Moka',          2, 13.00,  50),  -- id 4
    ('Limonada Frozen',         2,  9.50,  70),  -- id 5
    ('Té Helado',               2,  7.00,  90),  -- id 6
    ('Torta de Chocolate',      3, 12.00,  30),  -- id 7
    ('Cheesecake de Maracuyá',  3, 14.00,  25),  -- id 8
    ('Sándwich de Pollo',       4, 11.50,  40),  -- id 9
    ('Empanada de Queso',       4,  5.50,  60),  -- id 10
    ('Brownie con Helado',      3, 13.50,  20);  -- id 11

INSERT INTO clientes (nombre, apellido, correo, telefono, fecha_registro) VALUES
    ('Ana',   'Quispe',  'ana.quispe@correo.com',   '987654321', '2026-08-15'),  -- id 1
    ('Luis',  'Mamani',  'luis.mamani@correo.com',  '976543210', '2026-08-20'),  -- id 2
    ('María', 'Huamán',  'maria.huaman@correo.com', '965432109', '2026-09-01'),  -- id 3
    ('Carlos','Condori', 'carlos.condori@correo.com','954321098','2026-09-05'),  -- id 4
    ('Lucía', 'Flores',  'lucia.flores@correo.com', '943210987', '2026-09-10'),  -- id 5
    ('Jorge', 'Ramos',   'jorge.ramos@correo.com',  '932109876', '2026-09-18');  -- id 6

INSERT INTO pedidos (id_cliente, fecha_pedido, metodo_pago, estado) VALUES
    (1, '2026-09-03', 'Yape',     'Entregado'),  -- id 1
    (2, '2026-09-04', 'Efectivo', 'Entregado'),  -- id 2
    (1, '2026-09-12', 'Tarjeta',  'Entregado'),  -- id 3
    (3, '2026-09-15', 'Plin',     'Entregado'),  -- id 4
    (4, '2026-09-22', 'Efectivo', 'Entregado'),  -- id 5
    (5, '2026-09-28', 'Yape',     'Entregado'),  -- id 6
    (2, '2026-10-02', 'Tarjeta',  'Entregado'),  -- id 7
    (3, '2026-10-06', 'Yape',     'Entregado'),  -- id 8
    (1, '2026-10-10', 'Efectivo', 'Pendiente'),  -- id 9
    (4, '2026-10-14', 'Tarjeta',  'Entregado');  -- id 10

INSERT INTO detalle_pedidos (id_pedido, id_producto, cantidad, precio_unitario) VALUES
    (1,  1, 2,  6.50), (1, 10, 2,  5.50),
    (2,  2, 1,  9.00), (2,  7, 1, 12.00),
    (3,  4, 2, 13.00), (3,  9, 1, 11.50),
    (4,  3, 1,  8.50), (4,  8, 1, 14.00), (4, 10, 1, 5.50),
    (5,  5, 3,  9.50),
    (6,  1, 1,  6.50), (6,  2, 1,  9.00), (6,  7, 2, 12.00),
    (7,  6, 2,  7.00), (7,  9, 2, 11.50),
    (8,  2, 2,  9.00), (8,  8, 1, 14.00),
    (9,  4, 1, 13.00), (9, 10, 3,  5.50),
    (10, 1, 3,  6.50), (10, 9, 1, 11.50), (10, 7, 1, 12.00);

-- Verificación rápida: cantidad de registros por tabla
SELECT 'categorias' AS tabla, COUNT(*) AS registros FROM categorias
UNION ALL SELECT 'productos',       COUNT(*) FROM productos
UNION ALL SELECT 'clientes',        COUNT(*) FROM clientes
UNION ALL SELECT 'pedidos',         COUNT(*) FROM pedidos
UNION ALL SELECT 'detalle_pedidos', COUNT(*) FROM detalle_pedidos;
