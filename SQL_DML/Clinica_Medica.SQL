/*1. Exiba o código, nome e especialidade do médico requisitante que mais realizou
atendimentos.*/

SELECT MR.CODIGO, MR.NOME, MR.ESPECIALIDADE
FROM MEDICO_REQUISITANTE MR
JOIN (
    SELECT CODIGO_MEDICO_REQUISITANTE, COUNT(*) AS NUM_ATENDIMENTOS,
           DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS RN
    FROM ATENDIMENTO
    GROUP BY CODIGO_MEDICO_REQUISITANTE
) A ON MR.CODIGO = A.CODIGO_MEDICO_REQUISITANTE
WHERE A.RN = 1;

/*2. Liste o nome do paciente, o nome do médico requisitante e a data de atendimento para todos os atendimentos realizados no mês de Abril*/

SELECT p.NOME AS NOME_PACIENTE, mr.NOME AS NOME_MEDICO, ad.DATA_ATENDIMENTO
FROM ATENDIMENTO ad
JOIN MEDICO_REQUISITANTE mr ON ad.CODIGO_MEDICO_REQUISITANTE = mr.CODIGO
JOIN PACIENTE p ON ad.CPF_PACIENTE = p.CPF
WHERE EXTRACT(MONTH FROM ad.DATA_ATENDIMENTO) = 4;

/*3. Exiba o CPF do paciente, o nome do paciente e a quantidade de exames realizados por ele, ordenando o resultado pela quantidade de exames realizados de forma decrescente.*/

SELECT CPF, NOME, QUANTIDADE_EXAMES 
FROM PACIENTE JOIN 
(SELECT CPF_PACIENTE, COUNT(*) AS QUANTIDADE_EXAMES
    FROM (SELECT CPF_PACIENTE, CODIGO_EXAME 
            FROM (ATENDIMENTO JOIN EXAME_REQUERIDO_ATENDIMENTO 
            ON ATENDIMENTO.CODIGO = EXAME_REQUERIDO_ATENDIMENTO.CODIGO_ATENDIMENTO))
           GROUP BY CPF_PACIENTE ORDER BY QUANTIDADE_EXAMES DESC) 
           ON CPF = CPF_PACIENTE;


/*4. Exiba o nome do paciente, o nome do médico requisitante e a data de atendimento para todos os atendimentos em que o médico requisitante e o paciente possuem o mesmo estado.*/

SELECT PACIENTE.NOME AS NOME_PACIENTE, 
       MEDICO_REQUISITANTE.NOME AS NOME_MEDICO_REQUISITANTE, 
       ATENDIMENTO.DATA_ATENDIMENTO
FROM ATENDIMENTO
JOIN PACIENTE ON ATENDIMENTO.CPF_PACIENTE = PACIENTE.CPF
JOIN MEDICO_REQUISITANTE ON ATENDIMENTO.CODIGO_MEDICO_REQUISITANTE = MEDICO_REQUISITANTE.CODIGO
WHERE PACIENTE.END_ESTADO = MEDICO_REQUISITANTE.END_ESTADO;

/*5. Mostre o código e nome do médico requisitante que mais solicitou exames para pacientes do sexo feminino.*/

SELECT mr.CODIGO AS CODIGO_MEDICO, mr.NOME AS NOME_MEDICO
FROM ATENDIMENTO ad
JOIN MEDICO_REQUISITANTE mr ON ad.CODIGO_MEDICO_REQUISITANTE = mr.CODIGO
JOIN EXAME_REQUERIDO_ATENDIMENTO ex ON ad.CODIGO = ex.CODIGO_ATENDIMENTO
JOIN PACIENTE p ON ad.CPF_PACIENTE = p.CPF
WHERE p.SEXO = 'FEMININO'
GROUP BY mr.CODIGO, mr.NOME
ORDER BY COUNT(*) DESC
FETCH FIRST 1 ROW ONLY;

/*6. Obter o CPF e nome do paciente, o nome do médico requisitante e a data de atendimento para todos os atendimentos realizados em 2024.*/

SELECT P.CPF, P.NOME, MR.NOME AS NOME_MEDICO_REQUISITANTE, DATA_ATENDIMENTO 
FROM MEDICO_REQUISITANTE MR 
JOIN (
    SELECT CPF, NOME, CODIGO_MEDICO_REQUISITANTE, DATA_ATENDIMENTO
    FROM PACIENTE
    JOIN (
        SELECT CPF_PACIENTE, CODIGO_MEDICO_REQUISITANTE, DATA_ATENDIMENTO 
        FROM ATENDIMENTO
        WHERE EXTRACT(YEAR FROM DATA_ATENDIMENTO) = 2024
        ) 
    ON CPF = CPF_PACIENTE) P
ON MR.CODIGO = CODIGO_MEDICO_REQUISITANTE;

/*7. Obter o código e nome do médico elaborador e o número total de dependentes cadastrados para cada um deles.*/

SELECT ME.CODIGO AS CODIGO_MEDICO_ELABORADOR,
       ME.NOME AS NOME_MEDICO_ELABORADOR,
       COUNT(D.CODIGO_DEPENDENTE) AS TOTAL_DEPENDENTES
FROM MEDICO_ELABORADOR ME
LEFT JOIN DEPENDENTE D ON ME.CODIGO = D.CODIGO_MEDICO_ELABORADOR
GROUP BY ME.CODIGO, ME.NOME;

/*8. Liste o código e o nome do médico requisitante e o número total de atendimentos realizados por ele nos fins de semana.*/

SELECT
    MR.CODIGO AS CODIGO_MEDICO,
    MR.NOME AS NOME_MEDICO,
    COUNT(*) AS TOTAL_ATENDIMENTOS_FIM_DE_SEMANA
FROM
    MEDICO_REQUISITANTE MR
JOIN
    ATENDIMENTO A ON MR.CODIGO = A.CODIGO_MEDICO_REQUISITANTE
WHERE
    TO_CHAR(A.DATA_ATENDIMENTO, 'D') IN ('1', '7') -- 1 para domingo e 7 para sábado
GROUP BY
    MR.CODIGO, MR.NOME;

/*9. Obtenha o código e o nome do médico elaborador e o valor total dos exames por especialidade que ele elaborou.*/

SELECT 
    MEDICO_ELABORADOR.CODIGO AS CODIGO_MEDICO,
    MEDICO_ELABORADOR.NOME AS NOME_MEDICO,
    MEDICO_ELABORADOR.ESPECIALIDADE AS ESPECIALIDADE_MEDICO,
    SUM(EXAME_PROVIDO.PRECO) AS VALOR_TOTAL_EXAMES
FROM 
    MEDICO_ELABORADOR
JOIN 
    EXAME ON MEDICO_ELABORADOR.CODIGO = EXAME.CODIGO_MEDICO_ELABORADOR
JOIN 
    EXAME_PROVIDO ON EXAME.CODIGO = EXAME_PROVIDO.CODIGO_EXAME
GROUP BY 
    MEDICO_ELABORADOR.CODIGO, 
    MEDICO_ELABORADOR.NOME, 
    MEDICO_ELABORADOR.ESPECIALIDADE
ORDER BY 
    MEDICO_ELABORADOR.ESPECIALIDADE;


/*10. Exibir o código e nome do médico elaborador e a média de salário dos médicos elaboradores que têm pelo menos 5 anos de experiência.*/

SELECT CODIGO, NOME, 
    (SELECT SUM(SALARIO)/COUNT(*)   
FROM MEDICO_ELABORADOR 
    WHERE MONTHS_BETWEEN(SYSDATE, DATA_ADMISSAO) >= 60) AS MEDIA_SALARIO
FROM MEDICO_ELABORADOR
WHERE MONTHS_BETWEEN(SYSDATE, DATA_ADMISSAO) >= 60 GROUP BY CODIGO, NOME






/*FASE 2*/






/*1. Crie uma view chamada media_exame_convenio que exibe o código e nome
do convênio juntamente com a média dos seus exames ofertados.*/

CREATE VIEW media_exame_convenio AS
SELECT 
c.CODIGO_ANS, c.NOME AS NOME_CONVENIO, 
       ROUND(COUNT(e.CODIGO) / CAST((SELECT COUNT(*) FROM CONVENIO_MEDICO_REQUISITANTE WHERE CODIGO_ANS = c.CODIGO_ANS) AS FLOAT), 1) AS MEDIA_EXAMES
FROM 
CONVENIO c
LEFT JOIN 
CONVENIO_MEDICO_REQUISITANTE cmr ON c.CODIGO_ANS = cmr.CODIGO_ANS
LEFT JOIN 
REQUISICAO_EXAME re ON cmr.CODIGO_MEDICO_REQUISITANTE = re.CODIGO_MEDICO_REQUISITANTE
LEFT JOIN 
EXAME e ON re.CODIGO_EXAME = e.CODIGO
GROUP BY c.CODIGO_ANS, c.NOME;

/*2. Crie uma view chamada melhor_medico_plano_saude_a que exiba o nome e
código do médico requisitante que mais realizou exames no convênio ‘Plano
de Saúde A’.*/

CREATE VIEW melhor_medico_plano_saude_a AS
SELECT MR.CODIGO AS CODIGO_MEDICO, MR.NOME AS NOME_MEDICO
FROM MEDICO_REQUISITANTE MR
JOIN (
    SELECT A.CODIGO_MEDICO_REQUISITANTE, COUNT(*) AS QTD_EXAMES
    FROM EXAME_REQUERIDO_ATENDIMENTO EA
    JOIN ATENDIMENTO A ON EA.CODIGO_ATENDIMENTO = A.CODIGO
    JOIN CONVENIO C ON A.CODIGO_ANS = C.CODIGO_ANS
    WHERE C.NOME = 'Plano de Saúde A'
    GROUP BY A.CODIGO_MEDICO_REQUISITANTE
    ORDER BY COUNT(*) DESC
) T1 ON MR.CODIGO = T1.CODIGO_MEDICO_REQUISITANTE
WHERE ROWNUM = 1;



/*3. Crie uma view chamada pacientes_masculino_frequentes que liste o CPF e o
nome de todos os pacientes do sexo ‘Masculino’, que realizaram mais de 3
atendimentos.*/

CREATE VIEW pacientes_masculino_frequentes(CPF, NOME)
    AS 
    SELECT PACIENTE.CPF, PACIENTE.NOME FROM
    (PACIENTE JOIN 
    (SELECT CPF_PACIENTE, COUNT(*)
    FROM ATENDIMENTO 
    GROUP BY ATENDIMENTO.CPF_PACIENTE HAVING COUNT(*) > 3)
    ON PACIENTE.CPF = CPF_PACIENTE)
    WHERE PACIENTE.SEXO = 'Masculino';

/*4. Crie uma view chamada atendimentos_convenio que exibe o código e nome
do convênio juntamente com a média de atendimentos feitos por ele.*/

CREATE VIEW atendimentos_convenio AS SELECT 
    c.CODIGO_ANS,
    c.NOME AS NOME_CONVENIO,
    ROUND(COUNT(a.CODIGO) / CAST((SELECT COUNT(*) FROM CONVENIO) AS FLOAT), 1) AS MEDIA_ATENDIMENTOS
FROM 
    CONVENIO c
LEFT JOIN 
    ATENDIMENTO a ON c.CODIGO_ANS = a.CODIGO_ANS
GROUP BY c.CODIGO_ANS, c.NOME;

/*5. Crie uma procedure chamada inserir_ddd_rio que troca os dois primeiros
dígitos do(s) telefone(s) para 21, para todos os pacientes que moram no ‘Rio
de Janeiro’.*/

CREATE OR REPLACE PROCEDURE inserir_ddd_rio IS
BEGIN
    UPDATE PACIENTE
    SET telefone = '21' || SUBSTR(telefone, 3)
    WHERE END_CIDADE = 'Rio de Janeiro';
END inserir_ddd_rio;
/


/*6. Crie uma procedure chamada aumenta_salario_medico_elaborador, que
recebe o código de um médico elaborador e caso ele tenha realizado mais
exames do que a média de exames realizados por todos os médicos
elaboradores, ele vai receber um aumento de 30% em seu salário.*/

CREATE OR REPLACE PROCEDURE aumenta_salario_medico_elaborador (codigo_medico IN NUMBER) IS
    media_exames NUMBER;
    total_exames_medico NUMBER;
BEGIN
    SELECT AVG(contagem)
    INTO media_exames
    FROM (
        SELECT COUNT(*) AS contagem
        FROM exames
        GROUP BY codigo_medico_elaborador
    );

    SELECT COUNT(*)
    INTO total_exames_medico
    FROM exames
    WHERE codigo_medico_elaborador = codigo_medico;

    IF total_exames_medico > media_exames THEN
        UPDATE medicos
        SET salario = salario * 1.3
        WHERE codigo = codigo_medico;
    END IF;
END aumenta_salario_medico_elaborador;
/

/*7. Crie uma função chamada penalize_medico_elaborador que recebe o código
de um exame e se a nota dele for menor que 5, a data de demissão do
médico elaborador responsável tem que ser a data atual.*/

CREATE OR REPLACE FUNCTION penalize_medico_elaborador(
  p_codigo_exame IN NUMBER
)
RETURN NUMBER
IS
  v_nota_exame NUMBER;
  v_data_demissao DATE;
BEGIN
  SELECT NOTA INTO v_nota_exame
  FROM EXAME
  WHERE CODIGO = p_codigo_exame;

  IF v_nota_exame < 5 THEN
    UPDATE MEDICO_ELABORADOR
    SET DATA_DEMISSAO = SYSDATE
    WHERE CODIGO = (SELECT CODIGO_MEDICO_ELABORADOR FROM EXAME WHERE CODIGO = p_codigo_exame);
    
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
END;
/


/*8. Crie um trigger chamado definir_data_demissao que ao ser cadastrado um
médico elaborador, define a sua data de demissão como sendo exatamente
um ano depois da sua data de admissão.*/

CREATE OR REPLACE TRIGGER definir_data_demissao
BEFORE INSERT ON MEDICO_ELABORADOR
FOR EACH ROW

BEGIN 
    :NEW.DATA_DEMISSAO := ADD_MONTHS(:NEW.DATA_ADMISSAO,12);
END;


/*9. Crie um trigger chamado validar_datas que, ao ser inserido ou atualizado um
médico elaborador, verifique se a data de admissão é anterior à data de
demissão.*/

CREATE OR REPLACE TRIGGER validar_datas
BEFORE INSERT OR UPDATE ON MEDICO_ELABORADOR
FOR EACH ROW
DECLARE
BEGIN
    IF :NEW.DATA_ADMISSAO IS NOT NULL AND :NEW.DATA_DEMISSAO IS NOT NULL THEN
        IF :NEW.DATA_ADMISSAO >= :NEW.DATA_DEMISSAO THEN
            RAISE_APPLICATION_ERROR(-20001, 'A data de admissão deve ser anterior à data de demissão.');
        END IF;
    END IF;
END;
/

/*10.Crie um trigger chamado validar_cep_paciente que, ao ser inserido ou
atualizado o endereço de um paciente, verifique se o CEP fornecido tem 8
dígitos.*/

CREATE OR REPLACE TRIGGER validar_cep_paciente
BEFORE INSERT OR UPDATE OF END_CEP ON PACIENTE
FOR EACH ROW
DECLARE
    v_cep_length NUMBER;’ 
BEGIN
    v_cep_length := LENGTH(:NEW.END_CEP);
    IF v_cep_length != 8 THEN
        RAISE_APPLICATION_ERROR(-20001, 'O CEP fornecido deve ter exatamente 8 dígitos.');
    END IF;
END;
/




