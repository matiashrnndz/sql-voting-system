-- BASES DE DATOS 2 - OBLIGATORIO

---------------------------------------------------------- PROCEDURES ----------------------------------------------------------

-- PROCEDURE : CONTROL DE PADRON --

CREATE OR REPLACE PROCEDURE CONTROL_DE_PADRON
IS
    resultado NUMBER(10);
BEGIN
    DBMS_OUTPUT.put_line('-- Se comienza la busqueda de cantidad de votantes habilitados --');

    SELECT COUNT(*)
    INTO resultado 
    FROM VOTANTE VOT
    WHERE VOT.HABILITADO = 'V';

    DBMS_OUTPUT.put_line(resultado);
    
    DBMS_OUTPUT.put_line('-- Se finaliza la busqueda de cantidad de votantes habilitados --');

END CONTROL_DE_PADRON;

-- PROCEDURE : CIERRE DE VOTACION --

CREATE OR REPLACE PROCEDURE CIERRE_DE_VOTACION (VOTACION NUMBER, INTEGRANTE NUMBER)
IS
    hay_votacion NUMBER(1) := 0;
    integrante_electoral number(1) := 0;
    vot_id NUMBER(10) := VOTACION;
    integrante_nro NUMBER(10) := INTEGRANTE;

    CURSOR curLista IS (SELECT L.VOTACION_ID, L.NUMERO, L.VOTOS_DIRECTIVA, L.VOTOS_ELECTORAL, L.VOTOS_FISCAL
                        FROM LISTA L, VOTACION V
                        WHERE L.VOTACION_ID = vot_id);
    regLista curLista%ROWTYPE;

    CURSOR curMocion IS (SELECT M.NOMBRE, M.APROBACION_APROBADA, M.APROBACION_RECHAZADA, M.APROBACION_ENBLANCO,
                                M.SELECCION_APROBADA, M.SELECCION_RECHAZADA, M.SELECCION_ENBLANCO
                         FROM MOCION M, VOTACION V
                         WHERE M.VOTACION_ID = vot_id);
    regMocion curMocion%ROWTYPE;
BEGIN
    DBMS_OUTPUT.put_line('-- Se comienza el cierre de votacion --');

    SELECT CASE
               WHEN COUNT(*) > 0 THEN 1
               ELSE 0 
           END
    INTO integrante_electoral
    FROM INTEGRANTE_COMISION I
    WHERE I.VOTACION_ID = vot_id
      AND I.VOTANTE_NRO_AFILIADO = integrante_nro
      AND I.COMISION_TIPO = 'ELECTORAL'
      AND I.PENDIENTE = 'F';

    IF (integrante_electoral = 1) THEN
        UPDATE VOTACION
        SET ESTADO = 'CERRADO'
        WHERE ID = vot_id;

        DBMS_OUTPUT.put_line('-- Votacion directiva : --');

        FOR regLista IN curLista LOOP
            DBMS_OUTPUT.put_line('-- Lista : ' || regLista.NUMERO || ' --');
            DBMS_OUTPUT.put_line('-- Votos directiva : ' || regLista.VOTOS_DIRECTIVA || ' --');
            DBMS_OUTPUT.put_line('-- Votos fiscal : ' || regLista.VOTOS_FISCAL || ' --');
            DBMS_OUTPUT.put_line('-- Votos electoral : ' || regLista.VOTOS_ELECTORAL || ' --');
        END LOOP;

        DBMS_OUTPUT.put_line('-- Votacion de aprobacion de mocion : --');

        FOR regMocion IN curMocion LOOP
            DBMS_OUTPUT.put_line('-- Mocion : ' || regMocion.NOMBRE || ' --');
            DBMS_OUTPUT.put_line('-- Aprobadas : ' || regMocion.APROBACION_APROBADA || ' --');
            DBMS_OUTPUT.put_line('-- Rechazadas : ' || regMocion.APROBACION_RECHAZADA || ' --');
            DBMS_OUTPUT.put_line('-- En blanco : ' || regMocion.APROBACION_ENBLANCO || ' --');
        END LOOP;

        DBMS_OUTPUT.put_line('-- Votacion de seleccion de mocion : --');

        FOR regMocion IN curMocion LOOP
            DBMS_OUTPUT.put_line('-- Mocion : ' || regMocion.NOMBRE || ' --');
            DBMS_OUTPUT.put_line('-- Aprobadas : ' || regMocion.SELECCION_APROBADA || ' --');
            DBMS_OUTPUT.put_line('-- Rechazadas : ' || regMocion.SELECCION_RECHAZADA || ' --');
            DBMS_OUTPUT.put_line('-- En blanco : ' || regMocion.SELECCION_ENBLANCO|| ' --');
        END LOOP;
    ELSE
        DBMS_OUTPUT.put_line('El integrante debe ser de la comisi�n Electoral');
    END IF;
    
    COMMIT;
    
    DBMS_OUTPUT.put_line('-- Se finaliza el cierre de votacion --');
END CIERRE_DE_VOTACION;

-- PROCEDURE : CONTROL DE VOTACION DE USUARIO --

CREATE OR REPLACE PROCEDURE CONTROL_VOTACION_DE_USUARIO(NRO_AFILIADO NUMBER, VOTACION_ID NUMBER)
IS
    id_votante NUMBER(10) := NRO_AFILIADO;
    id_vot NUMBER(10) := VOTACION_ID;
    id_res NUMBER(10) := 0;
BEGIN
    DBMS_OUTPUT.put_line('-- Se comienza el control de votacion de usuario --');

    SELECT COUNT(*)
    INTO id_res
    FROM CONTROL_VOTACION CV
    WHERE CV.VOTANTE_NRO_AFILIADO = id_votante
      AND CV.VOTACION_ID = id_vot;
      
    IF (id_res > 0) THEN 
        DBMS_OUTPUT.put_line('Ha votado');
    ELSE
        DBMS_OUTPUT.put_line('No ha votado');
    END IF;

    DBMS_OUTPUT.put_line('-- Se finaliza el control de votacion de usuario --');
END CONTROL_VOTACION_DE_USUARIO;

-- PROCEDURE : RESUMEN DE VOTACIONES --

CREATE OR REPLACE PROCEDURE RESUMEN_DE_VOTACIONES  (INICIO_VOT DATE, FINAL_VOT DATE)
IS
    inicio_votacion DATE := INICIO_VOT;
    final_votacion DATE := FINAL_VOT;
    hay_materializacion NUMBER(1);
    resumen_materializado VARCHAR(4000);
    
    CURSOR curVotacion IS (SELECT V.ID, V.ESTADO, V.INICIO, V.FIN
                           FROM VOTACION V
                           WHERE (V.INICIO BETWEEN inicio_votacion AND final_votacion)
                             AND (V.FIN BETWEEN inicio_votacion AND final_votacion));
    regVotacion curVotacion%ROWTYPE;

    CURSOR curLista IS (SELECT L.VOTACION_ID, L.NUMERO, L.VOTOS_DIRECTIVA, L.VOTOS_ELECTORAL, L.VOTOS_FISCAL
                        FROM LISTA L, VOTACION V
                        WHERE L.VOTACION_ID = V.ID
                          AND (V.INICIO BETWEEN inicio_votacion AND final_votacion)
                          AND (V.FIN BETWEEN inicio_votacion AND final_votacion));
    regLista curLista%ROWTYPE;

    CURSOR curMocion IS (SELECT M.NOMBRE, M.APROBACION_APROBADA, M.APROBACION_RECHAZADA, M.APROBACION_ENBLANCO,
                                M.SELECCION_APROBADA, M.SELECCION_RECHAZADA, M.SELECCION_ENBLANCO
                         FROM MOCION M, VOTACION V
                         WHERE M.VOTACION_ID = V.ID
                           AND (V.INICIO BETWEEN inicio_votacion AND final_votacion)
                           AND (V.FIN BETWEEN inicio_votacion AND final_votacion));
    regMocion curMocion%ROWTYPE;
BEGIN
    DBMS_OUTPUT.put_line('-- Se comienza la eliminacion de votacion --');
    
    SELECT CASE
           WHEN COUNT(*) > 0 THEN 1
           ELSE 0 
       END
    INTO hay_materializacion
    FROM MATERIALIZACION_RESUMEN r
    WHERE r.INICIO = inicio_votacion
      AND r.FIN = final_votacion;
        
    IF (hay_materializacion = 1)
        THEN 
            DBMS_OUTPUT.put_line('-- Se obtiene resumen materializado --');
            
            SELECT RESUMEN
            INTO resumen_materializado
            FROM MATERIALIZACION_RESUMEN R
            WHERE R.INICIO = inicio_votacion
              AND R.FIN = final_votacion;
              
            DBMS_OUTPUT.put_line(resumen_materializado);
    ELSE
        FOR regVotacion IN curVotacion LOOP

            resumen_materializado := resumen_materializado || chr(10) || '-- Votacion : ' || regVotacion.ID || ', fecha : ' || regVotacion.INICIO || ' - ' || regVotacion.FIN || ' --';
            DBMS_OUTPUT.put_line('-- Votacion : ' || regVotacion.ID || ', fecha : ' || regVotacion.INICIO || ' - ' || regVotacion.FIN || ' --');
            
            resumen_materializado := resumen_materializado || chr(10) || '-- Votacion directiva : --';
            DBMS_OUTPUT.put_line('-- Votacion directiva : --');
    
            FOR regLista IN curLista LOOP
                resumen_materializado := resumen_materializado || chr(10) || '-- Lista : ' || regLista.NUMERO || ' --';
                DBMS_OUTPUT.put_line('-- Lista : ' || regLista.NUMERO || ' --');
                resumen_materializado := resumen_materializado || chr(10) || '-- Votos directiva : ' || regLista.VOTOS_DIRECTIVA || ' --';
                DBMS_OUTPUT.put_line('-- Votos directiva : ' || regLista.VOTOS_DIRECTIVA || ' --');
                resumen_materializado := resumen_materializado || chr(10) || '-- Votos fiscal : ' || regLista.VOTOS_FISCAL || ' --';
                DBMS_OUTPUT.put_line('-- Votos fiscal : ' || regLista.VOTOS_FISCAL || ' --');
                resumen_materializado := resumen_materializado || chr(10) || '-- Votos electoral : ' || regLista.VOTOS_ELECTORAL || ' --';
                DBMS_OUTPUT.put_line('-- Votos electoral : ' || regLista.VOTOS_ELECTORAL || ' --');
            END LOOP;
    
            resumen_materializado := resumen_materializado || chr(10) || '-- Votacion de aprobacion de mocion : --';
            DBMS_OUTPUT.put_line('-- Votacion de aprobacion de mocion : --');
    
            FOR regMocion IN curMocion LOOP
                resumen_materializado := resumen_materializado || chr(10) || '-- Mocion : ' || regMocion.NOMBRE || ' --';
                DBMS_OUTPUT.put_line('-- Mocion : ' || regMocion.NOMBRE || ' --');
                resumen_materializado := resumen_materializado || chr(10) || '-- Aprobadas : ' || regMocion.APROBACION_APROBADA || ' --';
                DBMS_OUTPUT.put_line('-- Aprobadas : ' || regMocion.APROBACION_APROBADA || ' --');
                resumen_materializado := resumen_materializado || chr(10) || '-- Rechazadas : ' || regMocion.APROBACION_RECHAZADA || ' --';
                DBMS_OUTPUT.put_line('-- Rechazadas : ' || regMocion.APROBACION_RECHAZADA || ' --');
                resumen_materializado := resumen_materializado || chr(10) || '-- En blanco : ' || regMocion.APROBACION_ENBLANCO || ' --';
                DBMS_OUTPUT.put_line('-- En blanco : ' || regMocion.APROBACION_ENBLANCO || ' --');
            END LOOP;
    
            resumen_materializado := resumen_materializado || chr(10) || '-- Votacion de seleccion de mocion : --';
            DBMS_OUTPUT.put_line('-- Votacion de seleccion de mocion : --');
    
            FOR regMocion IN curMocion LOOP
                resumen_materializado := resumen_materializado || chr(10) || '-- Mocion : ' || regMocion.NOMBRE || ' --';
                DBMS_OUTPUT.put_line('-- Mocion : ' || regMocion.NOMBRE || ' --');
                resumen_materializado := resumen_materializado || chr(10) || '-- Aprobadas : ' || regMocion.SELECCION_APROBADA || ' --';
                DBMS_OUTPUT.put_line('-- Aprobadas : ' || regMocion.SELECCION_APROBADA || ' --');
                resumen_materializado := resumen_materializado || chr(10) || '-- Rechazadas : ' || regMocion.SELECCION_RECHAZADA || ' --';
                DBMS_OUTPUT.put_line('-- Rechazadas : ' || regMocion.SELECCION_RECHAZADA || ' --');
                resumen_materializado := resumen_materializado || chr(10) || '-- En blanco : ' || regMocion.SELECCION_ENBLANCO|| ' --';
                DBMS_OUTPUT.put_line('-- En blanco : ' || regMocion.SELECCION_ENBLANCO|| ' --');
            END LOOP;
    
            UPDATE VOTACION
            SET ESTADO = 'PUBLICADA'
            WHERE ID = regVotacion.ID;
            
        END LOOP;
        
    END IF;
    
    IF (hay_materializacion = 0) THEN
        INSERT INTO MATERIALIZACION_RESUMEN (INICIO, FIN, RESUMEN)
        VALUES (inicio_votacion, final_votacion, resumen_materializado);
    END IF;

    DBMS_OUTPUT.put_line('-- Se finaliza la eliminacion de votacion --');
END RESUMEN_DE_VOTACIONES;

-- PROCEDURE : ELIMINACION DE VOTACION --

CREATE OR REPLACE PROCEDURE ELIMINACION_DE_VOTACION (VOTACION NUMBER, INTEGRANTE NUMBER)
IS
    hay_votacion NUMBER(1) := 0;
    integrante_electoral number(1) := 0;
    vot_id NUMBER(10) := VOTACION;
    integrante_nro NUMBER(10) := INTEGRANTE;
BEGIN
    DBMS_OUTPUT.put_line('-- Se comienza la eliminacion de votacion --');
    
    SELECT CASE
               WHEN COUNT(*) > 0 THEN 1
               ELSE 0 
           END
    INTO integrante_electoral
    FROM INTEGRANTE_COMISION I
    WHERE I.VOTACION_ID = vot_id
      AND I.VOTANTE_NRO_AFILIADO = integrante_nro
      AND I.COMISION_TIPO = 'ELECTORAL'
      AND I.PENDIENTE = 'F';
        
    IF (integrante_electoral = 1) THEN
    
        SELECT CASE
               WHEN COUNT(*) > 0 THEN 1
               ELSE 0 
           END
        INTO hay_votacion
        FROM VOTACION V
        WHERE V.ID = vot_id;
    
        IF (hay_votacion = 1) THEN
        
            DELETE
            FROM HOSPEDAJE H
            WHERE H.EVENTO_ID = vot_id;
            DBMS_OUTPUT.put_line('-- Se borraron los hospedajes para esa votacion --');
            DELETE
            FROM COMPRAS_EVENTO C
            WHERE C.EVENTO_ID = vot_id;
            DBMS_OUTPUT.put_line('-- Se borraron las compras del evento para esa votacion --');
            DELETE
            FROM EVENTO E
            WHERE E.VOTACION_ID = vot_id;
            DBMS_OUTPUT.put_line('-- Se borro el evento para esa votacion --');
            DELETE
            FROM CONTROL_VOTACION C
            WHERE C.VOTACION_ID = vot_id;
            DBMS_OUTPUT.put_line('-- Se borro el control de votos para ese evento para esa votacion --');
            DELETE
            FROM VOTO V
            WHERE V.VOTACION_ID = vot_id;
            DBMS_OUTPUT.put_line('-- Se borraron los votos para esa votacion --');
            DELETE
            FROM MOCION M
            WHERE M.VOTACION_ID = vot_id;
            DBMS_OUTPUT.put_line('-- Se borraron las mociones para esa votacion --');
            DELETE
            FROM INTEGRANTE_COMISION I
            WHERE I.VOTACION_ID = vot_id;
            DBMS_OUTPUT.put_line('-- Se borraron los integrantes de comision para esa votacion --');
            DELETE
            FROM LISTA L
            WHERE L.VOTACION_ID = vot_id;
            DBMS_OUTPUT.put_line('-- Se borraron las listas para esa votacion --');
            DELETE
            FROM VOTACION V
            WHERE V.ID = vot_id;
            DBMS_OUTPUT.put_line('-- Se borro la votacion --');
        ELSE
            DBMS_OUTPUT.put_line('No existe la votacion ingresada.');  
        END IF;
    ELSE
        DBMS_OUTPUT.put_line('El usuario no integra a la comision electoral.');  
    END IF;
    
    COMMIT;

    DBMS_OUTPUT.put_line('-- Se finaliza la eliminacion de votacion --');
END ELIMINACION_DE_VOTACION;

-- PROCEDURE : RESUMEN DE GASTOS --

CREATE OR REPLACE PROCEDURE RESUMEN_DE_GASTOS (STARTDATE DATE, ENDDATE DATE)
IS
    start_date DATE := STARTDATE;
    end_date DATE := ENDDATE;
    resumen VARCHAR2(1000);

    CURSOR curCompras IS (SELECT C.EVENTO_ID, C.FECHA, C.ADMINISTRATIVO_NRO_ADMIN, C.MONEDA, C.MONTO, C.TIPO_CAMBIO
                          FROM COMPRAS_EVENTO C
                          WHERE (C.FECHA BETWEEN start_date AND end_date));
    regCompras curCompras%ROWTYPE;

BEGIN
    DBMS_OUTPUT.put_line('-- Se comienza el resumen de gastos --');

    FOR regCompras IN curCompras LOOP
        IF (regCompras.MONEDA = 'N') THEN
            resumen := 'Evento : ' || regCompras.EVENTO_ID || ', FECHA : ' || regCompras.FECHA ||
            ', ADMINISTRATIVO : ' || regCompras.ADMINISTRATIVO_NRO_ADMIN || ', MONTO EN PESOS : ' ||
            regCompras.MONTO || ', MONTO EN DOLARES : ' || (regCompras.MONTO / regCompras.TIPO_CAMBIO);
        ELSE
            resumen := 'Evento : ' || regCompras.EVENTO_ID || ', FECHA : ' || regCompras.FECHA ||
            ', ADMINISTRATIVO : ' || regCompras.ADMINISTRATIVO_NRO_ADMIN || ', MONTO EN PESOS : ' ||
            (regCompras.MONTO * regCompras.TIPO_CAMBIO || ', MONTO EN DOLARES : ' || regCompras.MONTO);
        END IF;
        DBMS_OUTPUT.put_line(resumen);
    END LOOP;

    DBMS_OUTPUT.put_line('-- Se finaliza el resumen de gastos --');
END RESUMEN_DE_GASTOS;

-- PROCEDURE : BAJA DE USUARIO --

CREATE OR REPLACE PROCEDURE BAJA_DE_USUARIO (NRO_AFILIADO NUMBER, MOTIVO VARCHAR)
IS
    votante_id NUMBER(10) := NRO_AFILIADO;
    motivo_baja VARCHAR(255) := MOTIVO;
BEGIN
    DBMS_OUTPUT.put_line('-- Se comienza la baja del usuario --');

    DELETE  
    FROM VOTANTE VOT
    WHERE VOT.NRO_AFILIADO = votante_id;

    DBMS_OUTPUT.put_line('-- Se borra el usuario --');

    INSERT INTO REGISTRO_DESAFILIACION
    VALUES (votante_id, motivo_baja, SYSDATE);

    DBMS_OUTPUT.put_line('-- Se registra la desafiliacion del usuario --');

    COMMIT;
    
    DBMS_OUTPUT.put_line('-- Se finaliza la baja del usuario --');
END BAJA_DE_USUARIO;

---------------------------------------------------------- EJECUTABLES ----------------------------------------------------------

-- PROCEDURE : CONTROL DE PADRON --

BEGIN
    CONTROL_DE_PADRON();
END;

-- PROCEDURE : CIERRE DE VOTACION --

BEGIN
    CIERRE_DE_VOTACION(2, 2);
END;

-- PROCEDURE : CONTROL DE VOTACION DE USUARIO --

-- Ha votado
BEGIN
    CONTROL_VOTACION_DE_USUARIO(1, 2);
END;

-- No ha votado
BEGIN
    CONTROL_VOTACION_DE_USUARIO(5, 2);
END;

-- PROCEDURE : RESUMEN DE VOTACIONES --

BEGIN
    RESUMEN_DE_VOTACIONES(TO_DATE('2018/01/02 01:00:00', 'YYYY/MM/DD HH:MI:SS'), TO_DATE('2018/01/03 03:00:00', 'YYYY/MM/DD HH:MI:SS'));
END;

BEGIN
    RESUMEN_DE_VOTACIONES(TO_DATE('2018/01/01 01:00:00', 'YYYY/MM/DD HH:MI:SS'), TO_DATE('2018/01/03 03:00:00', 'YYYY/MM/DD HH:MI:SS'));
END;

-- PROCEDURE : ELIMINACION DE VOTACION --

BEGIN
    ELIMINACION_DE_VOTACION(5, 5);
END;

-- PROCEDURE : RESUMEN DE GASTOS --

BEGIN
    RESUMEN_DE_GASTOS(TO_DATE('2018/01/02 01:00:00', 'YYYY/MM/DD HH:MI:SS'), TO_DATE('2018/02/20 9:00:00', 'YYYY/MM/DD HH:MI:SS'));
END;

-- PROCEDURE : BAJA DE USUARIO --

BEGIN
    BAJA_DE_USUARIO(6, 'Dice que netbeans es un lenguaje de programacion');
END;

-- PROCEDURE : RESUMEN DE VOTACIONES --



