SET SERVEROUTPUT ON;

DECLARE
    -- 1. USO DE VARRAY (IE1.1.1)
    -- Lo usaremos para definir las zonas de despacho que la tienda cubre hoy.
    TYPE Tipo_Zonas_Despacho IS VARRAY(3) OF VARCHAR2(50);
    v_zonas Tipo_Zonas_Despacho := Tipo_Zonas_Despacho('Puerto Montt', 'Puerto Varas', 'Llanquihue');

    -- 2. USO DE RECORD (IE1.1.1)
    -- Estructura para agrupar los datos del artículo que estamos validando.
    TYPE Registro_Articulo IS RECORD (
        nombre_articulo Articulo_Venta.nombre_articulo%TYPE,
        stock_actual    Articulo_Venta.stock_disponible%TYPE,
        precio_venta    Detalle_Orden.precio_historico_venta%TYPE,
        cantidad_req    Detalle_Orden.cantidad%TYPE
    );
    v_datos_art Registro_Articulo;

    -- 3. CURSORES EXPLÍCITOS COMPLEJOS CON PARÁMETROS (IE1.2.1)
    
    -- Cursor Principal: Busca clientes según la zona de despacho (parámetro).
    CURSOR c_clientes (p_comuna VARCHAR2) IS
        SELECT id_cliente, nombre_completo, direccion_calle, telefono
        FROM Cliente
        WHERE comuna = p_comuna;

    -- Cursor Secundario: Busca el detalle de las compras del cliente (parámetro).
    CURSOR c_compras_cliente (p_id_cliente INTEGER) IS
        SELECT a.nombre_articulo, a.stock_disponible, d.precio_historico_venta, d.cantidad
        FROM Orden_Compra o
        JOIN Detalle_Orden d ON o.id_orden = d.Orden_Compra_id_orden
        JOIN Articulo_Venta a ON d.Articulo_Venta_id_articulo = a.id_articulo
        WHERE o.Cliente_id_cliente = p_id_cliente;

    -- 4. EXCEPCIONES DEFINIDAS POR EL USUARIO (IE1.3.1)
    EXC_STOCK_INSUFICIENTE EXCEPTION;
    
    -- Variables auxiliares
    v_total_orden INTEGER := 0;
    v_hubo_clientes BOOLEAN := FALSE;

BEGIN
    DBMS_OUTPUT.PUT_LINE('======================================================');
    DBMS_OUTPUT.PUT_LINE('INICIO DE REPORTE DE DESPACHOS Y VALIDACIÓN DE STOCK');
    DBMS_OUTPUT.PUT_LINE('======================================================');

    -- Primer Loop: Recorremos el VARRAY de zonas geográficas
    FOR i IN 1..v_zonas.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('>>> Procesando Zona de Despacho: ' || v_zonas(i));
        v_hubo_clientes := FALSE;

        -- Segundo Loop (Anidado): Recorremos el Cursor de Clientes parametrizado
        FOR v_cliente IN c_clientes(v_zonas(i)) LOOP
            v_hubo_clientes := TRUE;
            DBMS_OUTPUT.PUT_LINE('    Cliente: ' || v_cliente.nombre_completo || ' | Ruta: ' || v_cliente.direccion_calle);
            v_total_orden := 0;

            -- Tercer Loop (Anidado múltiple): Recorremos el Cursor de Órdenes parametrizado
            FOR v_compra IN c_compras_cliente(v_cliente.id_cliente) LOOP
                
                -- Guardamos la información en nuestro RECORD
                v_datos_art.nombre_articulo := v_compra.nombre_articulo;
                v_datos_art.stock_actual    := v_compra.stock_disponible;
                v_datos_art.precio_venta    := v_compra.precio_historico_venta;
                v_datos_art.cantidad_req    := v_compra.cantidad;

                DBMS_OUTPUT.PUT_LINE('        - Evaluando Artículo: ' || v_datos_art.nombre_articulo);

                -- Sub-bloque para el manejo específico de excepciones por artículo
                BEGIN
                    -- Lógica de negocio: Validar si hay stock físico suficiente
                    IF v_datos_art.stock_actual < v_datos_art.cantidad_req THEN
                        RAISE EXC_STOCK_INSUFICIENTE; -- Disparamos la excepción de usuario
                    END IF;

                    DBMS_OUTPUT.PUT_LINE('          [OK] Stock validado (' || v_datos_art.stock_actual || ' disp). Total línea: $' || (v_datos_art.precio_venta * v_datos_art.cantidad_req));
                    v_total_orden := v_total_orden + (v_datos_art.precio_venta * v_datos_art.cantidad_req);

                EXCEPTION
                    -- Capturamos la excepción de usuario sin detener todo el proceso
                    WHEN EXC_STOCK_INSUFICIENTE THEN
                        DBMS_OUTPUT.PUT_LINE('          [ERROR] STOCK INSUFICIENTE para ' || v_datos_art.nombre_articulo || '. Stock actual: ' || v_datos_art.stock_actual);
                END;

            END LOOP;
            
            DBMS_OUTPUT.PUT_LINE('    Monto total validado para ' || v_cliente.nombre_completo || ': $' || v_total_orden);
            DBMS_OUTPUT.PUT_LINE('    --------------------------------------------------');

        END LOOP;

        IF NOT v_hubo_clientes THEN
            DBMS_OUTPUT.PUT_LINE('    * No hay clientes registrados con compras en esta zona.');
            DBMS_OUTPUT.PUT_LINE('    --------------------------------------------------');
        END IF;
    END LOOP;

EXCEPTION
    -- Excepciones predefinidas por Oracle (IE1.3.1)
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR CRÍTICO: No se encontraron datos durante el proceso de búsqueda.');
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('ERROR CRÍTICO: Intento de división por cero en los cálculos.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLCODE || ' - ' || SQLERRM);
END;
/