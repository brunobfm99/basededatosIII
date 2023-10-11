Trigger de tipo sentencia para la tabla FACTURAS:
CREATE OR REPLACE TRIGGER trg_facturas
AFTER INSERT OR UPDATE OR DELETE ON hr.facturas
DECLARE
    v_operacion CHAR(1);
BEGIN
    IF INSERTING THEN
        v_operacion := 'I';
    ELSIF UPDATING THEN
        v_operacion := 'U';
    ELSIF DELETING THEN
        v_operacion := 'D';
    END IF;

    INSERT INTO hr.control_log (cod_empleado, fecha, tabla, cod_operacion)
    VALUES (USER, SYSDATE, 'FACTURAS', v_operacion);
END trg_facturas;
/
/*Trigger de tipo sentencia para la tabla LINEAS_FACTURA:*/
CREATE OR REPLACE TRIGGER trg_lineas_factura
AFTER INSERT OR UPDATE OR DELETE ON hr.lineas_factura
DECLARE
    v_operacion CHAR(1);
BEGIN
    IF INSERTING THEN
        v_operacion := 'I';
    ELSIF UPDATING THEN
        v_operacion := 'U';
    ELSIF DELETING THEN
        v_operacion := 'D';
    END IF;

    INSERT INTO hr.control_log (cod_empleado, fecha, tabla, cod_operacion)
    VALUES (USER, SYSDATE, 'LINEAS_FACTURA', v_operacion);
END trg_lineas_factura;
/
/*Trigger de tipo fila para la tabla LINEAS_FACTURA:*/
CREATE OR REPLACE TRIGGER trg_actualizar_total_vendido
AFTER INSERT OR UPDATE OR DELETE ON hr.lineas_factura
FOR EACH ROW
DECLARE
    v_total_vendido_anterior NUMBER;
BEGIN
    IF INSERTING OR UPDATING THEN
        SELECT total_vendidos INTO v_total_vendido_anterior
        FROM hr.productos
        WHERE cod_producto = :NEW.cod_producto;

        IF INSERTING THEN
            UPDATE hr.productos
            SET total_vendidos = COALESCE(v_total_vendido_anterior, 0) + :NEW.unidades
            WHERE cod_producto = :NEW.cod_producto;
        ELSIF UPDATING THEN
            UPDATE hr.productos
            SET total_vendidos = COALESCE(v_total_vendido_anterior, 0) + :NEW.unidades - :OLD.unidades
            WHERE cod_producto = :NEW.cod_producto;
        END IF;
    ELSIF DELETING THEN
        UPDATE hr.productos
        SET total_vendidos = COALESCE(v_total_vendido_anterior, 0) - :OLD.unidades
        WHERE cod_producto = :OLD.cod_producto;
    END IF;
END trg_actualizar_total_vendido;
/