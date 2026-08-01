DELIMITER //

CREATE PROCEDURE GerarDadosLeitura(
    IN p_dataInicio DATE,
    IN p_dataFim DATE,
    IN p_idLote INT,
    IN p_umidadeMin DECIMAL(5,2),
    IN p_umidadeMax DECIMAL(5,2),
    IN p_temperaturaMin DECIMAL(5,2),
    IN p_temperaturaMax DECIMAL(5,2),
    IN p_co2Max DECIMAL(7,2)
)
BEGIN
    DECLARE v_dataAtual DATE;
    DECLARE v_hora INT;
    DECLARE v_umidade DECIMAL(5,2);
    DECLARE v_temperatura DECIMAL(5,2);
    DECLARE v_co2 DECIMAL(7,2);
    DECLARE v_luz VARCHAR(10);
    DECLARE i INT;

    SET v_dataAtual = p_dataInicio;

    WHILE v_dataAtual <= p_dataFim DO
        SET v_hora = 0;

        WHILE v_hora < 24 DO
            
            -- Licht ligado entre 06:00 e 18:00
            IF v_hora >= 6 AND v_hora < 18 THEN
                SET v_luz = 'ligado';
            ELSE
                SET v_luz = 'desligado';
            END IF;

            -- 3 leituras por hora
            SET i = 1;
            WHILE i <= 3 DO
                
                SET v_umidade = p_umidadeMin + (RAND() * (p_umidadeMax - p_umidadeMin));
                SET v_temperatura = p_temperaturaMin + (RAND() * (p_temperaturaMax - p_temperaturaMin));
                SET v_co2 = RAND() * p_co2Max;

                INSERT INTO leitura (idLote, umidade, temperatura, co2, luz, dataCriacao)
                VALUES (
                    p_idLote,
                    ROUND(v_umidade, 2),
                    ROUND(v_temperatura, 2),
                    ROUND(v_co2, 2),
                    v_luz,
                    ADDTIME(
                        CONCAT(v_dataAtual, ' ', LPAD(v_hora, 2, '0'), ':00:00'),
                        SEC_TO_TIME(FLOOR(RAND() * 3600))
                    )
                );

                SET i = i + 1;
            END WHILE;

            SET v_hora = v_hora + 1;

        END WHILE;

        SET v_dataAtual = DATE_ADD(v_dataAtual, INTERVAL 1 DAY);
    END WHILE;

END //

DELIMITER ;


CALL GerarDadosLeitura(
    '2025-10-13',
    '2025-11-28',
    6,
    80, 92, 
    20, 26, 
    800
);
