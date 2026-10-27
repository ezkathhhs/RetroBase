SET SERVEROUTPUT ON;

DECLARE
    v_id_nueva_orden INTEGER := 6001; -- ID ficticio para nuestra prueba
    v_total_calculado INTEGER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('======================================================');
    DBMS_OUTPUT.PUT_LINE('    INICIO DE PRUEBA: E-COMMERCE RETRO (EVALUACIÓN 2) ');
    DBMS_OUTPUT.PUT_LINE('======================================================');

    -- PASO 0: Crear la cabecera de la orden para el cliente 2 (Roberto)
    INSERT INTO Orden_Compra (id_orden, Cliente_id_cliente, fecha_compra, total_pagado, estado_orden)
    VALUES (v_id_nueva_orden, 2, SYSDATE, 0, 'En Proceso');

    DBMS_OUTPUT.PUT_LINE('1. PRUEBA DE PROCEDIMIENTO CON PARÁMETROS Y TRIGGERS');
    DBMS_OUTPUT.PUT_LINE('>> Agregando 2 cartuchos de Super Mario World (SNES) a la orden ' || v_id_nueva_orden || '...');
    
    -- PASO 1: Llamamos al PROCEDIMIENTO de nuestro PACKAGE
    -- Al insertar, esto activará automáticamente AMBOS TRIGGERS (El de stock y el de auditoría).
    PKG_GESTION_RETRO.SP_AGREGAR_CARRITO(
        p_id_orden => v_id_nueva_orden, 
        p_id_articulo => 1001, 
        p_cantidad => 2
    );

    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('2. PRUEBA DE FUNCIÓN CON PARÁMETROS');
    
    -- PASO 2: Llamamos a la FUNCIÓN de nuestro PACKAGE para ver cuánto debe pagar
    v_total_calculado := PKG_GESTION_RETRO.FN_CALCULAR_TOTAL(v_id_nueva_orden);
    DBMS_OUTPUT.PUT_LINE('>> El total a pagar calculado por la función es: $' || v_total_calculado);
    
    -- Actualizamos la orden con el total real
    UPDATE Orden_Compra SET total_pagado = v_total_calculado WHERE id_orden = v_id_nueva_orden;

    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('3. PRUEBA DE PROCEDIMIENTO SIN PARÁMETROS');
    
    -- PASO 3: Llamamos al PROCEDIMIENTO de reporte para ver si el stock descontado generó alertas
    PKG_GESTION_RETRO.SP_REPORTE_STOCK_CRITICO;

    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('4. PRUEBA DE TRIGGER A NIVEL DE SENTENCIA (AUDITORÍA)');
    
    -- PASO 4: Hacemos un pequeño loop para leer el último registro que el Trigger guardó solo
    FOR v_log IN (SELECT * FROM Auditoria_Ventas ORDER BY id_auditoria DESC FETCH FIRST 1 ROWS ONLY) LOOP
        DBMS_OUTPUT.PUT_LINE('>> LOG AUTOGENERADO: ' || v_log.descripcion || ' | Por: ' || v_log.usuario_db);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('======================================================');
    DBMS_OUTPUT.PUT_LINE('                     FIN DE LA PRUEBA                 ');
    DBMS_OUTPUT.PUT_LINE('======================================================');

    -- PASO 5: Deshacemos todo para poder volver a probar sin arruinar los datos reales
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('* Nota de sistema: Se aplicó ROLLBACK. La base de datos está limpia.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
        ROLLBACK;
END;
/