-- ===================================================================
-- SCRIPT DML: Datos de Prueba
-- ===================================================================

-- 1. Insertar Plataformas
INSERT INTO Plataforma VALUES (1, 'Super Nintendo', 'Nintendo', 1990);
INSERT INTO Plataforma VALUES (2, 'Game Boy Advance', 'Nintendo', 2001);
INSERT INTO Plataforma VALUES (3, 'Sega Genesis', 'Sega', 1989);

-- 2. Insertar Géneros
INSERT INTO Genero VALUES (1, 'Plataformas');
INSERT INTO Genero VALUES (2, 'RPG');
INSERT INTO Genero VALUES (3, 'Acción / Aventura');

-- 3. Insertar Juegos (Metadatos)
INSERT INTO Juego VALUES (101, 'Super Mario World', 1990, 'Nintendo', 'Juego de plataformas clásico protagonizado por Mario y Yoshi.', 'N');
INSERT INTO Juego VALUES (102, 'The Legend of Zelda: A Link to the Past', 1991, 'Nintendo', 'Épica aventura RPG en el reino de Hyrule.', 'N');
INSERT INTO Juego VALUES (103, 'Sonic the Hedgehog', 1991, 'Sega', 'Juego de plataformas de alta velocidad con el erizo azul.', 'N');
INSERT INTO Juego VALUES (104, 'Pokémon Esmeralda', 2004, 'Game Freak', 'RPG de captura y entrenamiento de monstruos.', 'S');

-- 4. Asociar Juegos y Géneros
INSERT INTO Juego_Genero VALUES (101, 1);
INSERT INTO Juego_Genero VALUES (102, 3);
INSERT INTO Juego_Genero VALUES (103, 1);
INSERT INTO Juego_Genero VALUES (104, 2);

-- 5. Insertar Artículos en Venta (Solo Físicos: Cartuchos y Hardware)
INSERT INTO Articulo_Venta VALUES (1001, 'Cartucho Super Mario World (SNES)', 'Juego', 101, 1, 5, 'Físico', 'NTSC-U', 'Usado', 25000);
INSERT INTO Articulo_Venta VALUES (1002, 'Cartucho Zelda: A Link to the Past (SNES)', 'Juego', 102, 1, 2, 'Físico', 'NTSC-U', 'Usado', 35000);
-- Dejamos este juego con STOCK 0 a propósito para disparar la excepción en PL/SQL:
INSERT INTO Articulo_Venta VALUES (1003, 'Cartucho Pokémon Esmeralda (GBA)', 'Juego', 104, 2, 0, 'Físico', 'NTSC-U', 'Nuevo', 40000); 

INSERT INTO Articulo_Venta VALUES (2001, 'Consola BatleXP G350 Blanca', 'Consola', NULL, 1, 15, 'Físico', 'NTSC', 'Nuevo', 45000);
INSERT INTO Articulo_Venta VALUES (2002, 'Consola Anbernic RG35XX', 'Consola', NULL, 1, 20, 'Físico', 'NTSC', 'Nuevo', 55000);

-- 6. Insertar Clientes (Con datos de envío)
INSERT INTO Cliente VALUES (1, '21123456-7', 'Constanza Cardenas', 'ccardenas@correo.cl', '+56911223344', 'Guillermo Gallardo 123', 'Puerto Montt', 'Los Lagos', TO_DATE('10-01-2026', 'DD-MM-YYYY'));
INSERT INTO Cliente VALUES (2, '15987654-3', 'Roberto Gomez', 'rgomez@correo.cl', '+56999887766', 'Antonio Varas 502', 'Puerto Montt', 'Los Lagos', TO_DATE('15-02-2026', 'DD-MM-YYYY'));

-- 7. Insertar Órdenes de Compra y Detalles
-- Orden 1: Constanza compra un cartucho y una consola
INSERT INTO Orden_Compra VALUES (5001, 1, TO_DATE('20-02-2026', 'DD-MM-YYYY'), 70000, 'Completada');
INSERT INTO Detalle_Orden VALUES (5001, 1001, 1, 25000);
INSERT INTO Detalle_Orden VALUES (5001, 2001, 1, 45000);

-- Orden 2: Roberto compra un cartucho de Zelda
INSERT INTO Orden_Compra VALUES (5002, 2, TO_DATE('01-03-2026', 'DD-MM-YYYY'), 35000, 'Pendiente');
INSERT INTO Detalle_Orden VALUES (5002, 1002, 1, 35000);

COMMIT;