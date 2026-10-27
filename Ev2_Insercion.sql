-- PRUEBA DOS

-- 1. TABLA DE AUDITORÍA
-- Sirve para guardar un historial de seguridad automático.
CREATE TABLE Auditoria_Ventas (
    id_auditoria INTEGER GENERATED ALWAYS AS IDENTITY, -- Autoincrementable
    fecha_accion DATE,
    usuario_db VARCHAR2(50),
    descripcion VARCHAR2(200),
    CONSTRAINT Auditoria_Ventas_PK PRIMARY KEY (id_auditoria)
);
/

-- 2. TRIGGER A NIVEL DE FILA (Automatización de Stock)
-- Se dispara DESPUÉS de que se inserta un nuevo registro en Detalle_Orden.
-- El "FOR EACH ROW" indica que lo hará por cada artículo del carrito de compras.
CREATE OR REPLACE TRIGGER TRG_DESCONTAR_STOCK
AFTER INSERT ON Detalle_Orden
FOR EACH ROW
BEGIN
    -- :NEW hace referencia al nuevo dato que está entrando a la tabla Detalle_Orden
    UPDATE Articulo_Venta
    SET stock_disponible = stock_disponible - :NEW.cantidad
    WHERE id_articulo = :NEW.Articulo_Venta_id_articulo;
END;
/

-- 3. TRIGGER A NIVEL DE SENTENCIA (Auditoría de Seguridad)
-- Al NO tener "FOR EACH ROW", se dispara solo 1 vez al final de la inserción, 
-- sin importar si el cliente compró 1 o 50 artículos de golpe.
CREATE OR REPLACE TRIGGER TRG_AUDITORIA_VENTA_MASIVA
AFTER INSERT ON Detalle_Orden
BEGIN
    INSERT INTO Auditoria_Ventas (fecha_accion, usuario_db, descripcion)
    VALUES (SYSDATE, USER, 'Se registró exitosamente el detalle de una nueva orden de compra.');
END;
/

CREATE OR REPLACE PACKAGE PKG_GESTION_RETRO AS
    -- 1. Función Pública (Con parámetro)
    FUNCTION FN_CALCULAR_TOTAL(p_id_orden IN INTEGER) RETURN INTEGER;

    -- 2. Procedimiento Público (Con parámetros)
    PROCEDURE SP_AGREGAR_CARRITO(p_id_orden IN INTEGER, p_id_articulo IN INTEGER, p_cantidad IN INTEGER);

    -- 3. Procedimiento Público (Sin parámetros)
    PROCEDURE SP_REPORTE_STOCK_CRITICO;
END PKG_GESTION_RETRO;
/

CREATE OR REPLACE PACKAGE BODY PKG_GESTION_RETRO AS

    -- Variable privada (solo vive dentro del paquete)
    v_usuario_sesion VARCHAR2(50);

    -- 4. Función Privada (Sin parámetros) - Solo el paquete puede usarla
    FUNCTION FN_OBTENER_USUARIO RETURN VARCHAR2 IS
    BEGIN
        RETURN USER;
    END FN_OBTENER_USUARIO;

    -- Implementación: Función Pública
    FUNCTION FN_CALCULAR_TOTAL(p_id_orden IN INTEGER) RETURN INTEGER IS
        v_total INTEGER := 0;
    BEGIN
        -- ¿Por qué una Función y no un Procedimiento aquí?
        -- Porque las funciones DEVUELVEN obligatoriamente un valor (RETURN) y pueden usarse dentro de sentencias SELECT.
        SELECT NVL(SUM(cantidad * precio_historico_venta), 0)
        INTO v_total
        FROM Detalle_Orden
        WHERE Orden_Compra_id_orden = p_id_orden;
        
        RETURN v_total;
    END FN_CALCULAR_TOTAL;

    -- Implementación: Procedimiento Público con parámetros
    PROCEDURE SP_AGREGAR_CARRITO(p_id_orden IN INTEGER, p_id_articulo IN INTEGER, p_cantidad IN INTEGER) IS
        v_precio_actual INTEGER;
    BEGIN
        -- ¿Por qué un Procedimiento y no una Función aquí?
        -- Porque aquí vamos a MODIFICAR la base de datos (INSERT), no a calcular algo para devolverlo.
        SELECT precio_actual INTO v_precio_actual FROM Articulo_Venta WHERE id_articulo = p_id_articulo;

        INSERT INTO Detalle_Orden (Orden_Compra_id_orden, Articulo_Venta_id_articulo, cantidad, precio_historico_venta)
        VALUES (p_id_orden, p_id_articulo, p_cantidad, v_precio_actual);
        
        DBMS_OUTPUT.PUT_LINE('Agregado por: ' || v_usuario_sesion);
        -- OJO: Al hacer este INSERT, nuestro Trigger TRG_DESCONTAR_STOCK se disparará solo y restará el stock.
    END SP_AGREGAR_CARRITO;

    -- Implementación: Procedimiento Público sin parámetros
    PROCEDURE SP_REPORTE_STOCK_CRITICO IS
        CURSOR c_stock IS SELECT nombre_articulo, stock_disponible FROM Articulo_Venta WHERE stock_disponible <= 2;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- ALERTA DE INVENTARIO CRÍTICO ---');
        FOR v_item IN c_stock LOOP
            DBMS_OUTPUT.PUT_LINE(v_item.nombre_articulo || ' - Quedan: ' || v_item.stock_disponible || ' unidades.');
        END LOOP;
    END SP_REPORTE_STOCK_CRITICO;

    -- BLOQUE DE INICIALIZACIÓN (Constructor)
    BEGIN
        -- Este bloque se ejecuta una sola vez cuando llamas al paquete por primera vez.
        v_usuario_sesion := FN_OBTENER_USUARIO();
        DBMS_OUTPUT.PUT_LINE('Paquete inicializado correctamente para el usuario.');
END PKG_GESTION_RETRO;
/