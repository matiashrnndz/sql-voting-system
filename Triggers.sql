-- BASES DE DATOS 2 - OBLIGATORIO

---------------------------------------------------------- SECUENCIAS ----------------------------------------------------------

-- SEQUENCE : COMPRAS_EVENTO --

CREATE SEQUENCE COMPRAS_SEQ START WITH 1;

-- SEQUENCE : VOTO --

CREATE SEQUENCE VOTO_SEQ START WITH 1;

-- SEQUENCE : VOTACION --

CREATE SEQUENCE VOTACION_SEQ START WITH 1;

-- SEQUENCE : VOTANTE --

CREATE SEQUENCE VOTANTE_SEQ START WITH 1;

-- SEQUENCE : MOCION --

CREATE SEQUENCE MOCION_SEQ START WITH 1;

-- SEQUENCE : ADMINISTRATIVO --

CREATE SEQUENCE ADMINISTRATIVO_SEQ START WITH 1;

---------------------------------------------------------- TRIGGERS ------------------------------------------------------------

-- TRIGGERS : ADMINISTRATIVO --

CREATE OR REPLACE TRIGGER ADMINISTRATIVO_ID 
BEFORE INSERT ON ADMINISTRATIVO 
FOR EACH ROW
BEGIN
    SELECT ADMINISTRATIVO_SEQ.NEXTVAL
    INTO :new.NRO_ADMIN
    FROM DUAL;
END;

-- TRIGGERS : VOTANTE --

CREATE OR REPLACE TRIGGER VOTANTE_ID 
BEFORE INSERT ON VOTANTE 
FOR EACH ROW
BEGIN
    SELECT VOTANTE_SEQ.NEXTVAL
    INTO :new.NRO_AFILIADO
    FROM DUAL;
END;

CREATE OR REPLACE TRIGGER VOTANTE_CONTRASENA_INS 
BEFORE INSERT ON VOTANTE 
FOR EACH ROW
BEGIN
    :new.HABILITADO := 'F';
END;

CREATE OR REPLACE TRIGGER VOTANTE_CONTRASENA_UPD
BEFORE UPDATE OF CONTRASENA ON VOTANTE 
FOR EACH ROW
BEGIN
    :new.HABILITADO := 'T';
END;

-- TRIGGERS : VOTACION --

CREATE OR REPLACE TRIGGER VOTACION_ID 
BEFORE INSERT ON VOTACION 
FOR EACH ROW
BEGIN
    SELECT VOTACION_SEQ.NEXTVAL
    INTO :new.ID
    FROM DUAL;
END;

CREATE OR REPLACE TRIGGER VOTACION_HABILITADA_MAX1
AFTER INSERT OR UPDATE ON VOTACION
FOR EACH ROW
DECLARE
    CANT_HABILITADAS NUMBER(1);
BEGIN
    SELECT COUNT (*)
    INTO CANT_HABILITADAS
    FROM VOTACION V
    WHERE V.ESTADO = 'HABILITADA';
    
    IF (CANT_HABILITADAS >= 1)
        THEN raise_application_error(-20000, 'No se puede habilitar una instancia nueva de votacion hasta que la actual no haya terminado.');
    END IF;
END;

CREATE OR REPLACE TRIGGER VOTACION_ESTADOS
BEFORE UPDATE OF ESTADO ON VOTACION
FOR EACH ROW
BEGIN
    IF (:old.ESTADO = 'HABILITADA' AND (:new.ESTADO NOT IN ('HABILITADA', 'CERRADA')))
        THEN raise_application_error(-20000, 'No se puede cambiar el estado de una votacion de habilitada a un estado que no sea cerrada.');
    END IF;
    
    IF ((:old.ESTADO = 'CERRADA') AND (:new.ESTADO NOT IN ('CERRADA', 'PUBLICADA')))
        THEN raise_application_error(-20000, 'No se puede cambiar el estado de una votacion de cerrada a un estado que no sea cerrada o publicada.');
    END IF;
    
    IF ((:old.ESTADO = 'PUBLICADA') AND (:new.ESTADO <> 'PUBLICADA'))
        THEN raise_application_error(-20000, 'No se puede cambiar el estado de una votacion de publicada a otro estado.');
    END IF;
END;

-- TRIGGERS : LISTA --

CREATE OR REPLACE TRIGGER LISTA_MAX3_VOTACION
BEFORE INSERT ON LISTA
FOR EACH ROW
DECLARE
    CANT_LISTAS NUMBER;
    ESTADO_VOTACION VARCHAR(10);
BEGIN
    SELECT V.ESTADO
    INTO ESTADO_VOTACION
    FROM VOTACION V
    WHERE V.ID = :new.VOTACION_ID;
    
    IF (ESTADO_VOTACION <> 'BORRADOR')
        THEN raise_application_error(-20000, 'No se puede asignar una lista a una votacion que no este en estado borrador.');
    END IF;
    
    SELECT COUNT (*)
    INTO CANT_LISTAS
    FROM LISTA L
    WHERE L.VOTACION_ID = :new.VOTACION_ID;
    
    IF (CANT_LISTAS >= 3)
        THEN raise_application_error(-20000, 'No puede haber mas de 3 listas para una misma votacion.');
    END IF;
END;

-- TRIGGERS : INTEGRANTE_COMISION --

CREATE OR REPLACE TRIGGER INTEGRANTE_COMISION_MAX10
BEFORE INSERT ON INTEGRANTE_COMISION
FOR EACH ROW
DECLARE
    CANT_INTEGRANTES NUMBER;
BEGIN
    SELECT COUNT (*)
    INTO CANT_INTEGRANTES
    FROM INTEGRANTE_COMISION I
    WHERE :new.VOTACION_ID = I.VOTACION_ID
        AND :new.COMISION_TIPO = I.COMISION_TIPO;
    
    IF (CANT_INTEGRANTES >= 10)
        THEN raise_application_error(-20000, 'No puede haber mas de 10 integrantes en una misma comision.');
    END IF;
END;

-- TRIGGERS : MOCION --

CREATE OR REPLACE TRIGGER MOCION_ID 
BEFORE INSERT ON MOCION 
FOR EACH ROW
BEGIN
    SELECT MOCION_SEQ.NEXTVAL
    INTO :new.ID
    FROM DUAL;
END;

CREATE OR REPLACE TRIGGER MOCION_MAX10
BEFORE INSERT ON MOCION
FOR EACH ROW
DECLARE
    CANT_MOCIONES NUMBER;
    ESTADO_VOTACION VARCHAR(10);
BEGIN
    SELECT V.ESTADO
    INTO ESTADO_VOTACION
    FROM VOTACION V
    WHERE V.ID = :new.VOTACION_ID;
    
    IF (ESTADO_VOTACION <> 'BORRADOR')
        THEN raise_application_error(-20000, 'No se puede asignar una mocion a una votacion que no este en estado borrador.');
    END IF;
    
    SELECT COUNT (*)
    INTO CANT_MOCIONES
    FROM MOCION M
    WHERE :new.VOTACION_ID = M.VOTACION_ID;
    
    IF (CANT_MOCIONES >= 10)
        THEN raise_application_error(-20000, 'No puede haber mas de 10 integrantes en una misma comision.');
    END IF;
END;
                
-- TRIGGERS : REGISTRO_CAMBIOS_VOTANTE --

CREATE OR REPLACE TRIGGER REG_CAMB_VOT_FECHA
BEFORE INSERT OR UPDATE OF FECHA ON REGISTRO_CAMBIOS_VOTANTE 
FOR EACH ROW
BEGIN
    IF(:new.FECHA > sysdate) THEN
        raise_application_error(-20000, 'La fecha de la consulta no puede ser mayor a la fecha actual.');
    END IF;
END;

-- TRIGGERS : COMPRAS_EVENTO --

CREATE OR REPLACE TRIGGER COMPRAS_ID 
BEFORE INSERT ON COMPRAS_EVENTO 
FOR EACH ROW
BEGIN
    SELECT COMPRAS_SEQ.NEXTVAL
    INTO :new.ID
    FROM DUAL;
END;

CREATE OR REPLACE TRIGGER COMP_EVE_FECHA
BEFORE INSERT OR UPDATE OF FECHA ON COMPRAS_EVENTO 
FOR EACH ROW
BEGIN
    IF(:new.FECHA > sysdate) THEN
        raise_application_error(-20000, 'La fecha de la consulta no puede ser mayor a la fecha actual.');
    END IF;
END;

-- TRIGGERS : VOTO --

CREATE OR REPLACE TRIGGER VOTO_ID 
BEFORE INSERT ON VOTO 
FOR EACH ROW
BEGIN
    SELECT VOTO_SEQ.NEXTVAL
    INTO :new.ID
    FROM DUAL;
END;

CREATE OR REPLACE TRIGGER VOTO_VALIDACION
BEFORE INSERT ON VOTO
FOR EACH ROW
DECLARE
    ESTADO_VOTACION VARCHAR(10);
    CANT_VOTOS NUMBER(1);
    VALIDO VARCHAR(1);
    MOCION_VOTADA VARCHAR(50);
    MOCION_NRO NUMBER(2);
    CANT_MOCIONES NUMBER(2);
BEGIN
    SELECT ESTADO
    INTO ESTADO_VOTACION
    FROM VOTACION V
    WHERE V.ID = :new.VOTACION_ID;
    -- SI LA VOTACION NO ESTA EN ESTADO HABILITADA, NO SE PUEDE VOTAR
    IF (ESTADO_VOTACION <> 'HABILITADA')
        THEN raise_application_error(-20000, 'No se puede votar en una votacion que no esta habilitada.');
    END IF;
    -- DEPENDIENDO DEL TIPO DE VOTACION SE HACE UN PROCEDIMIENTO DIFERENTE
    CASE :new.TIPO_VOTACION
        -- CUANDO EL TIPO DE VOTACION ES DE DIRECTIVA
        WHEN 'DIRECTIVA' THEN
            IF ((:new.MOCION_1 IS NOT NULL) OR (:new.MOCION_2 IS NOT NULL) OR (:new.MOCION_3 IS NOT NULL) OR (:new.MOCION_4 IS NOT NULL) OR
                (:new.MOCION_5 IS NOT NULL) OR (:new.MOCION_6 IS NOT NULL) OR (:new.MOCION_7 IS NOT NULL) OR (:new.MOCION_8 IS NOT NULL) OR
                (:new.MOCION_9 IS NOT NULL) OR (:new.MOCION_10 IS NOT NULL))
                THEN raise_application_error(-20000, 'No se puede ingresar valores a otra votacion que no sea Directiva.');
            END IF;
            IF (:new.COMISION_DIRECTIVA IS NOT NULL) THEN
                UPDATE LISTA
                SET VOTOS_DIRECTIVA = VOTOS_DIRECTIVA + 1
                WHERE LISTA.VOTACION_ID = :new.VOTACION_ID
                  AND LISTA.NUMERO = :new.COMISION_DIRECTIVA;
            END IF;
            IF (:new.COMISION_FISCAL IS NOT NULL) THEN
                UPDATE LISTA
                SET VOTOS_FISCAL = VOTOS_FISCAL + 1
                WHERE LISTA.VOTACION_ID = :new.VOTACION_ID
                  AND LISTA.NUMERO = :new.COMISION_FISCAL;
            END IF;
            IF (:new.COMISION_ELECTORAL IS NOT NULL) THEN
                UPDATE LISTA
                SET VOTOS_ELECTORAL = VOTOS_ELECTORAL + 1
                WHERE LISTA.VOTACION_ID = :new.VOTACION_ID
                  AND LISTA.NUMERO = :new.COMISION_ELECTORAL;
            END IF;
        -- CUANDO EL TIPO DE VOTACION ES DE APROBACION DE MOCION    
        WHEN 'APROBACION MOCION' THEN
            VALIDO := 'F';
            IF ((:new.COMISION_DIRECTIVA IS NOT NULL) OR (:new.COMISION_FISCAL IS NOT NULL) OR (:new.COMISION_ELECTORAL IS NOT NULL))
                THEN raise_application_error(-20000, 'No pueden haber votos para la votacion directiva cuando se esta votando aprobacion de mocion.');
            END IF;
            -- CANTIDAD DE MOCIONES PARA ESTA VOTACION
            SELECT COUNT(*)
            INTO CANT_MOCIONES
            FROM MOCION M
            WHERE M.VOTACION_ID = :new.VOTACION_ID;

            VALIDO := 'F';

            IF(CANT_MOCIONES = 0)
                THEN raise_application_error(-20000, 'No puede haber votos a mociones si no hay mociones para dicha votacion.');
            END IF;
            -- SI HAY 1 MOCION PARA LA VOTACION
            IF(CANT_MOCIONES = 1) THEN
                IF ((:new.MOCION_1 IS NOT NULL) AND (:new.MOCION_2 IS NULL) AND (:new.MOCION_3 IS NULL) AND (:new.MOCION_4 IS NULL) AND
                (:new.MOCION_5 IS NULL) AND (:new.MOCION_6 IS NULL) AND (:new.MOCION_7 IS NULL) AND (:new.MOCION_8 IS NULL) AND
                (:new.MOCION_9 IS NULL) AND (:new.MOCION_10 IS NULL))
                    THEN VALIDO := 'T';
                END IF;
            END IF;
            -- SI HAY 2 MOCIONES PARA LA VOTACION
            IF(CANT_MOCIONES = 2) THEN
                IF ((:new.MOCION_1 IS NOT NULL) AND (:new.MOCION_2 IS NOT NULL) AND (:new.MOCION_3 IS NULL) AND (:new.MOCION_4 IS NULL) AND
                (:new.MOCION_5 IS NULL) AND (:new.MOCION_6 IS NULL) AND (:new.MOCION_7 IS NULL) AND (:new.MOCION_8 IS NULL) AND
                (:new.MOCION_9 IS NULL) AND (:new.MOCION_10 IS NULL))
                    THEN VALIDO := 'T';
                END IF;
            END IF;
            -- SI HAY 3 MOCIONES PARA LA VOTACION
            IF(CANT_MOCIONES = 3) THEN
                IF ((:new.MOCION_1 IS NOT NULL) AND (:new.MOCION_2 IS NOT NULL) AND (:new.MOCION_3 IS NOT NULL) AND (:new.MOCION_4 IS NULL) AND
                (:new.MOCION_5 IS NULL) AND (:new.MOCION_6 IS NULL) AND (:new.MOCION_7 IS NULL) AND (:new.MOCION_8 IS NULL) AND
                (:new.MOCION_9 IS NULL) AND (:new.MOCION_10 IS NULL))
                    THEN VALIDO := 'T';
                END IF;
            END IF;
            -- SI HAY 4 MOCIONES PARA LA VOTACION
            IF(CANT_MOCIONES = 4) THEN
                IF ((:new.MOCION_1 IS NOT NULL) AND (:new.MOCION_2 IS NOT NULL) AND (:new.MOCION_3 IS NOT NULL) AND (:new.MOCION_4 IS NOT NULL) AND
                (:new.MOCION_5 IS NULL) AND (:new.MOCION_6 IS NULL) AND (:new.MOCION_7 IS NULL) AND (:new.MOCION_8 IS NULL) AND
                (:new.MOCION_9 IS NULL) AND (:new.MOCION_10 IS NULL))
                    THEN VALIDO := 'T';
                END IF;
            END IF;
            -- SI HAY 5 MOCIONES PARA LA VOTACION
            IF(CANT_MOCIONES = 5) THEN
                IF ((:new.MOCION_1 IS NOT NULL) AND (:new.MOCION_2 IS NOT NULL) AND (:new.MOCION_3 IS NOT NULL) AND (:new.MOCION_4 IS NOT NULL) AND
                (:new.MOCION_5 IS NOT NULL) AND (:new.MOCION_6 IS NULL) AND (:new.MOCION_7 IS NULL) AND (:new.MOCION_8 IS NULL) AND
                (:new.MOCION_9 IS NULL) AND (:new.MOCION_10 IS NULL))
                    THEN VALIDO := 'T';
                END IF;
            END IF;
            -- SI HAY 6 MOCIONES PARA LA VOTACION
            IF(CANT_MOCIONES = 6) THEN
                IF ((:new.MOCION_1 IS NOT NULL) AND (:new.MOCION_2 IS NOT NULL) AND (:new.MOCION_3 IS NOT NULL) AND (:new.MOCION_4 IS NOT NULL) AND
                (:new.MOCION_5 IS NOT NULL) AND (:new.MOCION_6 IS NOT NULL) AND (:new.MOCION_7 IS NULL) AND (:new.MOCION_8 IS NULL) AND
                (:new.MOCION_9 IS NULL) AND (:new.MOCION_10 IS NULL))
                    THEN VALIDO := 'T';
                END IF;
            END IF;
            -- SI HAY 7 MOCIONES PARA LA VOTACION
            IF(CANT_MOCIONES = 7) THEN
                IF ((:new.MOCION_1 IS NOT NULL) AND (:new.MOCION_2 IS NOT NULL) AND (:new.MOCION_3 IS NOT NULL) AND (:new.MOCION_4 IS NOT NULL) AND
                (:new.MOCION_5 IS NOT NULL) AND (:new.MOCION_6 IS NOT NULL) AND (:new.MOCION_7 IS NOT NULL) AND (:new.MOCION_8 IS NULL) AND
                (:new.MOCION_9 IS NULL) AND (:new.MOCION_10 IS NULL))
                    THEN VALIDO := 'T';
                END IF;
            END IF;
            -- SI HAY 8 MOCIONES PARA LA VOTACION
            IF(CANT_MOCIONES = 8) THEN
                IF ((:new.MOCION_1 IS NOT NULL) AND (:new.MOCION_2 IS NOT NULL) AND (:new.MOCION_3 IS NOT NULL) AND (:new.MOCION_4 IS NOT NULL) AND
                (:new.MOCION_5 IS NOT NULL) AND (:new.MOCION_6 IS NOT NULL) AND (:new.MOCION_7 IS NOT NULL) AND (:new.MOCION_8 IS NOT NULL) AND
                (:new.MOCION_9 IS NULL) AND (:new.MOCION_10 IS NULL))
                    THEN VALIDO := 'T';
                END IF;
            END IF;
            -- SI HAY 9 MOCIONES PARA LA VOTACION
            IF(CANT_MOCIONES = 9) THEN
                IF ((:new.MOCION_1 IS NOT NULL) AND (:new.MOCION_2 IS NOT NULL) AND (:new.MOCION_3 IS NOT NULL) AND (:new.MOCION_4 IS NOT NULL) AND
                (:new.MOCION_5 IS NOT NULL) AND (:new.MOCION_6 IS NOT NULL) AND (:new.MOCION_7 IS NOT NULL) AND (:new.MOCION_8 IS NOT NULL) AND
                (:new.MOCION_9 IS NOT NULL) AND (:new.MOCION_10 IS NULL))
                    THEN VALIDO := 'T';
                END IF;
            END IF;
            -- SI HAY 10 MOCIONES PARA LA VOTACION
            IF(CANT_MOCIONES = 10) THEN
                IF ((:new.MOCION_1 IS NOT NULL) AND (:new.MOCION_2 IS NOT NULL) AND (:new.MOCION_3 IS NOT NULL) AND (:new.MOCION_4 IS NOT NULL) AND
                (:new.MOCION_5 IS NOT NULL) AND (:new.MOCION_6 IS NOT NULL) AND (:new.MOCION_7 IS NOT NULL) AND (:new.MOCION_8 IS NOT NULL) AND
                (:new.MOCION_9 IS NOT NULL) AND (:new.MOCION_10 IS NOT NULL))
                    THEN VALIDO := 'T';
                END IF;
            END IF;

            IF(VALIDO = 'F')
                THEN raise_application_error(-20000, 'No es un voto de aprobacion de mocion valido');
            END IF;

            IF(VALIDO = 'T') THEN
               IF (:new.MOCION_1 IS NOT NULL) THEN
                    SELECT NOMBRE
                    INTO MOCION_VOTADA
                    FROM (SELECT M.NOMBRE, ROW_NUMBER() OVER (ORDER BY ID) R
                          FROM MOCION M
                          WHERE M.VOTACION_ID = :new.VOTACION_ID)
                    WHERE R = 1;

                    IF (:new.MOCION_1 = 'APROBADA') THEN
                        UPDATE MOCION
                        SET APROBACION_APROBADA = APROBACION_APROBADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_1 = 'RECHAZADA') THEN
                        UPDATE MOCION
                        SET APROBACION_RECHAZADA = APROBACION_RECHAZADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_1 = 'EN BLANCO') THEN
                        UPDATE MOCION
                        SET APROBACION_ENBLANCO = APROBACION_ENBLANCO + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                END IF;
                IF (:new.MOCION_2 IS NOT NULL) THEN
                    SELECT NOMBRE
                    INTO MOCION_VOTADA
                    FROM (SELECT M.NOMBRE, ROW_NUMBER() OVER (ORDER BY ID) R
                          FROM MOCION M
                          WHERE M.VOTACION_ID = :new.VOTACION_ID)
                    WHERE R = 2;

                    IF (:new.MOCION_2 = 'APROBADA') THEN
                        UPDATE MOCION
                        SET APROBACION_APROBADA = APROBACION_APROBADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_2 = 'RECHAZADA') THEN
                        UPDATE MOCION
                        SET APROBACION_RECHAZADA = APROBACION_RECHAZADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_2 = 'EN BLANCO') THEN
                        UPDATE MOCION
                        SET APROBACION_ENBLANCO = APROBACION_ENBLANCO + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                END IF;
                IF (:new.MOCION_3 IS NOT NULL) THEN
                    SELECT NOMBRE
                    INTO MOCION_VOTADA
                    FROM (SELECT M.NOMBRE, ROW_NUMBER() OVER (ORDER BY ID) R
                          FROM MOCION M
                          WHERE M.VOTACION_ID = :new.VOTACION_ID)
                    WHERE R = 3;

                    IF (:new.MOCION_3 = 'APROBADA') THEN
                        UPDATE MOCION
                        SET APROBACION_APROBADA = APROBACION_APROBADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_3 = 'RECHAZADA') THEN
                        UPDATE MOCION
                        SET APROBACION_RECHAZADA = APROBACION_RECHAZADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_3 = 'EN BLANCO') THEN
                        UPDATE MOCION
                        SET APROBACION_ENBLANCO = APROBACION_ENBLANCO + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                END IF;
                IF (:new.MOCION_4 IS NOT NULL) THEN
                    SELECT NOMBRE
                    INTO MOCION_VOTADA
                    FROM (SELECT M.NOMBRE, ROW_NUMBER() OVER (ORDER BY ID) R
                          FROM MOCION M
                          WHERE M.VOTACION_ID = :new.VOTACION_ID)
                    WHERE R = 4;

                    IF (:new.MOCION_4 = 'APROBADA') THEN
                        UPDATE MOCION
                        SET APROBACION_APROBADA = APROBACION_APROBADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_4 = 'RECHAZADA') THEN
                        UPDATE MOCION
                        SET APROBACION_RECHAZADA = APROBACION_RECHAZADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_4 = 'EN BLANCO') THEN
                        UPDATE MOCION
                        SET APROBACION_ENBLANCO = APROBACION_ENBLANCO + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                END IF;
                IF (:new.MOCION_5 IS NOT NULL) THEN
                    SELECT NOMBRE
                    INTO MOCION_VOTADA
                    FROM (SELECT M.NOMBRE, ROW_NUMBER() OVER (ORDER BY ID) R
                          FROM MOCION M
                          WHERE M.VOTACION_ID = :new.VOTACION_ID)
                    WHERE R = 5;

                    IF (:new.MOCION_5 = 'APROBADA') THEN
                        UPDATE MOCION
                        SET APROBACION_APROBADA = APROBACION_APROBADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_5 = 'RECHAZADA') THEN
                        UPDATE MOCION
                        SET APROBACION_RECHAZADA = APROBACION_RECHAZADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_5 = 'EN BLANCO') THEN
                        UPDATE MOCION
                        SET APROBACION_ENBLANCO = APROBACION_ENBLANCO + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                END IF;
                IF (:new.MOCION_6 IS NOT NULL) THEN
                    SELECT NOMBRE
                    INTO MOCION_VOTADA
                    FROM (SELECT M.NOMBRE, ROW_NUMBER() OVER (ORDER BY ID) R
                          FROM MOCION M
                          WHERE M.VOTACION_ID = :new.VOTACION_ID)
                    WHERE R = 6;

                    IF (:new.MOCION_6 = 'APROBADA') THEN
                        UPDATE MOCION
                        SET APROBACION_APROBADA = APROBACION_APROBADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_6 = 'RECHAZADA') THEN
                        UPDATE MOCION
                        SET APROBACION_RECHAZADA = APROBACION_RECHAZADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_6 = 'EN BLANCO') THEN
                        UPDATE MOCION
                        SET APROBACION_ENBLANCO = APROBACION_ENBLANCO + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                END IF;
                IF (:new.MOCION_7 IS NOT NULL) THEN
                    SELECT NOMBRE
                    INTO MOCION_VOTADA
                    FROM (SELECT M.NOMBRE, ROW_NUMBER() OVER (ORDER BY ID) R
                          FROM MOCION M
                          WHERE M.VOTACION_ID = :new.VOTACION_ID)
                    WHERE R = 7;

                    IF (:new.MOCION_7 = 'APROBADA') THEN
                        UPDATE MOCION
                        SET APROBACION_APROBADA = APROBACION_APROBADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_7 = 'RECHAZADA') THEN
                        UPDATE MOCION
                        SET APROBACION_RECHAZADA = APROBACION_RECHAZADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_7 = 'EN BLANCO') THEN
                        UPDATE MOCION
                        SET APROBACION_ENBLANCO = APROBACION_ENBLANCO + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                END IF;
                IF (:new.MOCION_8 IS NOT NULL) THEN
                    SELECT NOMBRE
                    INTO MOCION_VOTADA
                    FROM (SELECT M.NOMBRE, ROW_NUMBER() OVER (ORDER BY ID) R
                          FROM MOCION M
                          WHERE M.VOTACION_ID = :new.VOTACION_ID)
                    WHERE R = 8;

                    IF (:new.MOCION_8 = 'APROBADA') THEN
                        UPDATE MOCION
                        SET APROBACION_APROBADA = APROBACION_APROBADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_8 = 'RECHAZADA') THEN
                        UPDATE MOCION
                        SET APROBACION_RECHAZADA = APROBACION_RECHAZADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_8 = 'EN BLANCO') THEN
                        UPDATE MOCION
                        SET APROBACION_ENBLANCO = APROBACION_ENBLANCO + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                END IF;
                IF (:new.MOCION_9 IS NOT NULL) THEN
                    SELECT NOMBRE
                    INTO MOCION_VOTADA
                    FROM (SELECT M.NOMBRE, ROW_NUMBER() OVER (ORDER BY ID) R
                          FROM MOCION M
                          WHERE M.VOTACION_ID = :new.VOTACION_ID)
                    WHERE R = 9;

                    IF (:new.MOCION_9 = 'APROBADA') THEN
                        UPDATE MOCION
                        SET APROBACION_APROBADA = APROBACION_APROBADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_9 = 'RECHAZADA') THEN
                        UPDATE MOCION
                        SET APROBACION_RECHAZADA = APROBACION_RECHAZADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_9 = 'EN BLANCO') THEN
                        UPDATE MOCION
                        SET APROBACION_ENBLANCO = APROBACION_ENBLANCO + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                END IF;
                IF (:new.MOCION_10 IS NOT NULL) THEN
                    SELECT NOMBRE
                    INTO MOCION_VOTADA
                    FROM (SELECT M.NOMBRE, ROW_NUMBER() OVER (ORDER BY ID) R
                          FROM MOCION M
                          WHERE M.VOTACION_ID = :new.VOTACION_ID)
                    WHERE R = 10;

                    IF (:new.MOCION_10 = 'APROBADA') THEN
                        UPDATE MOCION
                        SET APROBACION_APROBADA = APROBACION_APROBADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_10 = 'RECHAZADA') THEN
                        UPDATE MOCION
                        SET APROBACION_RECHAZADA = APROBACION_RECHAZADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                    IF (:new.MOCION_10 = 'EN BLANCO') THEN
                        UPDATE MOCION
                        SET APROBACION_ENBLANCO = APROBACION_ENBLANCO + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                        AND MOCION.NOMBRE = MOCION_VOTADA;
                    END IF;
                END IF;
            END IF;

        -- CUANDO EL TIPO DE VOTACION ES DE SELECCION DE MOCION      
        WHEN 'SELECCION MOCION' THEN
            VALIDO := 'F';
            IF ((:new.COMISION_DIRECTIVA IS NOT NULL) OR (:new.COMISION_FISCAL IS NOT NULL) OR (:new.COMISION_ELECTORAL IS NOT NULL))
                THEN raise_application_error(-20000, 'No pueden haber votos para la votacion directiva cuando se esta votando seleccion de mocion.');
            END IF;
             -- SI SE VOTO EN BLANCO A TODAS LAS MOCIONES
            IF ((:new.MOCION_1 = 'EN BLANCO' OR :new.MOCION_1 IS NULL) AND (:new.MOCION_2 = 'EN BLANCO' OR :new.MOCION_2 IS NULL) AND
                (:new.MOCION_3 = 'EN BLANCO' OR :new.MOCION_3 IS NULL) AND (:new.MOCION_4 = 'EN BLANCO' OR :new.MOCION_4 IS NULL) AND
                (:new.MOCION_5 = 'EN BLANCO' OR :new.MOCION_5 IS NULL) AND (:new.MOCION_6 = 'EN BLANCO' OR :new.MOCION_6 IS NULL) AND
                (:new.MOCION_7 = 'EN BLANCO' OR :new.MOCION_7 IS NULL) AND (:new.MOCION_8 = 'EN BLANCO' OR :new.MOCION_8 IS NULL) AND
                (:new.MOCION_9 = 'EN BLANCO' OR :new.MOCION_9 IS NULL) AND (:new.MOCION_10 = 'EN BLANCO' OR :new.MOCION_10 IS NULL))
                THEN
                    UPDATE MOCION
                    SET SELECCION_ENBLANCO = SELECCION_ENBLANCO + 1
                    WHERE MOCION.VOTACION_ID = :new.VOTACION_ID;
                    
                    VALIDO := 'T';
            -- SI SE VOTO RECHAZADA A TODAS LAS MOCIONES
            ELSE 
                IF ((:new.MOCION_1 = 'RECHAZADA' OR :new.MOCION_1 IS NULL) AND (:new.MOCION_2 = 'RECHAZADA'  OR :new.MOCION_2 IS NULL) AND
                    (:new.MOCION_3 = 'RECHAZADA' OR :new.MOCION_3 IS NULL) AND (:new.MOCION_4 = 'RECHAZADA'  OR :new.MOCION_4 IS NULL) AND
                    (:new.MOCION_5 = 'RECHAZADA' OR :new.MOCION_5 IS NULL) AND (:new.MOCION_6 = 'RECHAZADA'  OR :new.MOCION_6 IS NULL) AND
                    (:new.MOCION_7 = 'RECHAZADA' OR :new.MOCION_7 IS NULL) AND (:new.MOCION_8 = 'RECHAZADA'  OR :new.MOCION_8 IS NULL) AND
                    (:new.MOCION_9 = 'RECHAZADA' OR :new.MOCION_9 IS NULL) AND (:new.MOCION_10 = 'RECHAZADA' OR :new.MOCION_10 IS NULL))
                    THEN
                        UPDATE MOCION
                        SET SELECCION_RECHAZADA = SELECCION_RECHAZADA + 1
                        WHERE MOCION.VOTACION_ID = :new.VOTACION_ID;
                                
                        VALIDO := 'T';
                END IF;
            END IF;
            
            -- SI APROBO SOLO 1 DE LAS MOCIONES
            IF ((:new.MOCION_1 = 'APROBADA') AND ((:new.MOCION_2 <> 'APROBADA') AND (:new.MOCION_3 <> 'APROBADA') AND (:new.MOCION_4 <> 'APROBADA') AND
                (:new.MOCION_5 <> 'APROBADA') AND (:new.MOCION_6 <> 'APROBADA') AND (:new.MOCION_7 <> 'APROBADA') AND (:new.MOCION_8 <> 'APROBADA') AND
                (:new.MOCION_9 <> 'APROBADA') AND (:new.MOCION_10 <> 'APROBADA')))
                THEN MOCION_NRO := 1;
                     VALIDO := 'T';
            END IF;
            IF ((:new.MOCION_2 = 'APROBADA') AND ((:new.MOCION_1 <> 'APROBADA') AND (:new.MOCION_3 <> 'APROBADA') AND (:new.MOCION_4 <> 'APROBADA') AND
                (:new.MOCION_5 <> 'APROBADA') AND (:new.MOCION_6 <> 'APROBADA') AND (:new.MOCION_7 <> 'APROBADA') AND (:new.MOCION_8 <> 'APROBADA') AND
                (:new.MOCION_9 <> 'APROBADA') AND (:new.MOCION_10 <> 'APROBADA')))
                THEN MOCION_NRO := 2;
                     VALIDO := 'T';
            END IF;
            IF ((:new.MOCION_3 = 'APROBADA') AND ((:new.MOCION_1 <> 'APROBADA') AND (:new.MOCION_2 <> 'APROBADA') AND (:new.MOCION_4 <> 'APROBADA') AND
                (:new.MOCION_5 <> 'APROBADA') AND (:new.MOCION_6 <> 'APROBADA') AND (:new.MOCION_7 <> 'APROBADA') AND (:new.MOCION_8 <> 'APROBADA') AND
                (:new.MOCION_9 <> 'APROBADA') AND (:new.MOCION_10 <> 'APROBADA')))
                THEN MOCION_NRO := 3;
                     VALIDO := 'T';
            END IF;
            IF ((:new.MOCION_4 = 'APROBADA') AND ((:new.MOCION_1 <> 'APROBADA') AND (:new.MOCION_2 <> 'APROBADA') AND (:new.MOCION_3 <> 'APROBADA') AND
                (:new.MOCION_5 <> 'APROBADA') AND (:new.MOCION_6 <> 'APROBADA') AND (:new.MOCION_7 <> 'APROBADA') AND (:new.MOCION_8 <> 'APROBADA') AND
                (:new.MOCION_9 <> 'APROBADA') AND (:new.MOCION_10 <> 'APROBADA')))
                THEN MOCION_NRO := 4;
                     VALIDO := 'T';
            END IF;
            IF ((:new.MOCION_5 = 'APROBADA') AND ((:new.MOCION_1 <> 'APROBADA') AND (:new.MOCION_2 <> 'APROBADA') AND (:new.MOCION_3 <> 'APROBADA') AND
                (:new.MOCION_4 <> 'APROBADA') AND (:new.MOCION_6 <> 'APROBADA') AND (:new.MOCION_7 <> 'APROBADA') AND (:new.MOCION_8 <> 'APROBADA') AND
                (:new.MOCION_9 <> 'APROBADA') AND (:new.MOCION_10 <> 'APROBADA')))
                THEN MOCION_NRO := 5;
                     VALIDO := 'T';
            END IF;
            IF ((:new.MOCION_6 = 'APROBADA') AND ((:new.MOCION_1 <> 'APROBADA') AND (:new.MOCION_2 <> 'APROBADA') AND (:new.MOCION_3 <> 'APROBADA') AND
                (:new.MOCION_4 <> 'APROBADA') AND (:new.MOCION_5 <> 'APROBADA') AND (:new.MOCION_7 <> 'APROBADA') AND (:new.MOCION_8 <> 'APROBADA') AND
                (:new.MOCION_9 <> 'APROBADA') AND (:new.MOCION_10 <> 'APROBADA')))
                THEN MOCION_NRO := 6;
                     VALIDO := 'T';
            END IF;
            IF ((:new.MOCION_7 = 'APROBADA') AND ((:new.MOCION_1 <> 'APROBADA') AND (:new.MOCION_2 <> 'APROBADA') AND (:new.MOCION_3 <> 'APROBADA') AND
                (:new.MOCION_4 <> 'APROBADA') AND (:new.MOCION_5 <> 'APROBADA') AND (:new.MOCION_6 <> 'APROBADA') AND (:new.MOCION_8 <> 'APROBADA') AND
                (:new.MOCION_9 <> 'APROBADA') AND (:new.MOCION_10 <> 'APROBADA')))
                THEN MOCION_NRO := 7;
                     VALIDO := 'T';
            END IF;
            IF ((:new.MOCION_8 = 'APROBADA') AND ((:new.MOCION_1 <> 'APROBADA') AND (:new.MOCION_2 <> 'APROBADA') AND (:new.MOCION_3 <> 'APROBADA') AND
                (:new.MOCION_4 <> 'APROBADA') AND (:new.MOCION_5 <> 'APROBADA') AND (:new.MOCION_6 <> 'APROBADA') AND (:new.MOCION_7 <> 'APROBADA') AND
                (:new.MOCION_9 <> 'APROBADA') AND (:new.MOCION_10 <> 'APROBADA')))
                THEN MOCION_NRO := 8;
                     VALIDO := 'T';
            END IF;
            IF ((:new.MOCION_9 = 'APROBADA') AND ((:new.MOCION_1 <> 'APROBADA') AND (:new.MOCION_2 <> 'APROBADA') AND (:new.MOCION_3 <> 'APROBADA') AND
                (:new.MOCION_4 <> 'APROBADA') AND (:new.MOCION_5 <> 'APROBADA') AND (:new.MOCION_6 <> 'APROBADA') AND (:new.MOCION_7 <> 'APROBADA') AND
                (:new.MOCION_8 <> 'APROBADA') AND (:new.MOCION_10 <> 'APROBADA')))
                THEN MOCION_NRO := 9;
                     VALIDO := 'T';
            END IF;
            IF ((:new.MOCION_10 = 'APROBADA') AND ((:new.MOCION_1 <> 'APROBADA') AND (:new.MOCION_2 <> 'APROBADA') AND (:new.MOCION_3 <> 'APROBADA') AND
                (:new.MOCION_4 <> 'APROBADA') AND (:new.MOCION_5 <> 'APROBADA') AND (:new.MOCION_6 <> 'APROBADA') AND (:new.MOCION_7 <> 'APROBADA') AND
                (:new.MOCION_8 <> 'APROBADA') AND (:new.MOCION_9 <> 'APROBADA')))
                THEN MOCION_NRO := 10;
                     VALIDO := 'T';
            END IF;
            -- SI ENTRO A UNA DE LAS APROBADAS ANTERIORES, SE AGREGA UN VOTO A LA MOCION APROBADA
            IF (VALIDO = 'T')
                THEN
                    SELECT NOMBRE
                    INTO MOCION_VOTADA
                    FROM (SELECT M.NOMBRE, ROW_NUMBER() OVER (ORDER BY ID) R
                          FROM MOCION M
                          WHERE M.VOTACION_ID = :new.VOTACION_ID)
                    WHERE R = MOCION_NRO;

                    UPDATE MOCION
                    SET SELECCION_APROBADA = SELECCION_APROBADA + 1
                    WHERE MOCION.VOTACION_ID = :new.VOTACION_ID
                      AND MOCION.NOMBRE = MOCION_VOTADA;
            END IF;
            -- SI NO ENTRO A NINGUN CASO VALIDO, SE ANULA EL VOTO
            IF (VALIDO = 'F')
                THEN raise_application_error(-20000, 'Voto de seleccion de mocion invalido.');
            END IF;
    END CASE;
END;