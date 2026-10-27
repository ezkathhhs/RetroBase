-- ===================================================================
-- SCRIPT DDL: E-Commerce y Catálogo de Juegos Retro
-- ===================================================================

-- 1. CREACIÓN DE TABLAS MAESTRAS (Sin claves foráneas)76

CREATE TABLE Juego (
    id_juego INTEGER NOT NULL,
    titulo VARCHAR2(100) NOT NULL,
    anio_lanzamiento INTEGER NOT NULL,
    desarrollador VARCHAR2(100),
    sinopsis VARCHAR2(500),
    multijugador CHAR(1) NOT NULL,
    CONSTRAINT Juego_PK PRIMARY KEY (id_juego)
);

CREATE TABLE Genero (
    id_genero INTEGER NOT NULL,
    nombre_genero VARCHAR2(30) NOT NULL,
    CONSTRAINT Genero_PK PRIMARY KEY (id_genero)
);

CREATE TABLE Plataforma (
    id_plataforma INTEGER NOT NULL,
    nombre_plataforma VARCHAR2(50) NOT NULL,
    empresa_creadora VARCHAR2(50) NOT NULL,
    anio_salida INTEGER NOT NULL,
    CONSTRAINT Plataforma_PK PRIMARY KEY (id_plataforma)
);

CREATE TABLE Cliente (
    id_cliente INTEGER NOT NULL,
    rut VARCHAR2(12) NOT NULL,
    nombre_completo VARCHAR2(100) NOT NULL,
    correo VARCHAR2(100),
    telefono VARCHAR2(12),
    direccion_calle VARCHAR2(150), 
    comuna VARCHAR2(50),           
    region VARCHAR2(50),
    fecha_registro DATE NOT NULL,
    CONSTRAINT Cliente_PK PRIMARY KEY (id_cliente)
);

-- 2. CREACIÓN DE TABLAS DEPENDIENTES E INTERMEDIAS

CREATE TABLE Juego_Genero (
    Juego_id_juego INTEGER NOT NULL,
    Genero_id_genero INTEGER NOT NULL,
    CONSTRAINT Juego_Genero_PK PRIMARY KEY (Genero_id_genero, Juego_id_juego),
    CONSTRAINT Juego_Genero_Juego_FK FOREIGN KEY (Juego_id_juego) REFERENCES Juego (id_juego),
    CONSTRAINT Juego_Genero_Genero_FK FOREIGN KEY (Genero_id_genero) REFERENCES Genero (id_genero)
);

CREATE TABLE Articulo_Venta (
    id_articulo INTEGER NOT NULL,
    nombre_articulo VARCHAR2(100) NOT NULL, 
    tipo_articulo VARCHAR2(20) NOT NULL,  
    Juego_id_juego INTEGER,                 
    Plataforma_id_plataforma INTEGER NOT NULL,
    stock_disponible INTEGER NOT NULL,
    formato VARCHAR2(20) NOT NULL,
    region VARCHAR2(10),
    estado_articulo VARCHAR2(20),
    precio_actual INTEGER NOT NULL,
    CONSTRAINT Articulo_Venta_PK PRIMARY KEY (id_articulo),
    CONSTRAINT Articulo_Venta_Juego_FK FOREIGN KEY (Juego_id_juego) REFERENCES Juego (id_juego),
    CONSTRAINT Articulo_Venta_Plataforma_FK FOREIGN KEY (Plataforma_id_plataforma) REFERENCES Plataforma (id_plataforma)
);

CREATE TABLE Orden_Compra (
    id_orden INTEGER NOT NULL,
    Cliente_id_cliente INTEGER NOT NULL,
    fecha_compra DATE NOT NULL,
    total_pagado INTEGER NOT NULL,
    estado_orden VARCHAR2(20) NOT NULL,
    CONSTRAINT Orden_Compra_PK PRIMARY KEY (id_orden),
    CONSTRAINT Orden_Compra_Cliente_FK FOREIGN KEY (Cliente_id_cliente) REFERENCES Cliente (id_cliente)
);

CREATE TABLE Detalle_Orden (
    Orden_Compra_id_orden INTEGER NOT NULL,
    Articulo_Venta_id_articulo INTEGER NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_historico_venta INTEGER NOT NULL,
    CONSTRAINT Detalle_Orden_PK PRIMARY KEY (Articulo_Venta_id_articulo, Orden_Compra_id_orden),
    CONSTRAINT Detalle_Orden_Orden_Compra_FK FOREIGN KEY (Orden_Compra_id_orden) REFERENCES Orden_Compra (id_orden),
    CONSTRAINT Detalle_Orden_Articulo_Venta_FK FOREIGN KEY (Articulo_Venta_id_articulo) REFERENCES Articulo_Venta (id_articulo)
);

commit;

-- FIN DEL SCRIPT 