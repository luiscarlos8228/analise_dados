USE [analise_dados]
GO

/****** Object:  StoredProcedure [dbo].[PRC_AMAZON_PALAVRAS]    Script Date: 20/02/2024 19:49:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		LUIS CARLOS
-- Create date: 20/02/2024
-- Description:	INSERIR DADOS EM [dbo].[amazon_gc_palavras]
-- =============================================
CREATE PROCEDURE [dbo].[PRC_AMAZON_PALAVRAS]

AS
	SET NOCOUNT ON;

	-- APAGA A TABELAs TEMPORÁRIAs CASO EXITA
BEGIN
IF OBJECT_ID('tempdb..#palavras') IS NOT NULL
    DROP TABLE #palavras
END


-- RECRIA TABELA
BEGIN
    CREATE TABLE #palavras (
          ano int
		, palavra varchar(255)
		, contagem int
		, id int
    )

    -- CRIAÇÃO DE INDEX NA TABELA TEMPORARIA
    CREATE INDEX idx_palavra ON #palavras (palavra)
END

BEGIN
	INSERT INTO #palavras(ano, palavra, contagem, id)
		SELECT
		  ano
		, LOWER(palavras.value) AS palavra
		, COUNT(*) AS contagem
		, ROW_NUMBER() OVER (PARTITION BY ano ORDER BY count(*) desc) AS id

		FROM (
			SELECT 
				  YEAR(data_avaliacao) AS ano
				, REPLACE(REPLACE(texto, '.', ''), ',', '') AS texto_limpo
			FROM [dbo].[amazon_gift_cards]
		) AS limpo
		CROSS APPLY STRING_SPLIT(texto_limpo, ' ') AS palavras

		GROUP BY
		ano, LOWER(palavras.value)
		ORDER BY contagem DESC
END

BEGIN
	TRUNCATE TABLE analise_dados..amazon_gc_palavras

	INSERT INTO analise_dados..amazon_gc_palavras(ano, palavra, id)

	SELECT
	ano, palavra, id
	FROM #palavras
	WHERE LEN(palavra) > 1
	AND palavra NOT IN ('ourselves', 'hers', 'between', 'yourself', 'but', 'again'
		, 'there', 'about', 'once', 'during', 'out', 'very', 'having', 'with', 'they'
		, 'own', 'an', 'be', 'some', 'for', 'do', 'its', 'yours', 'such', 'into', 'of'
		, 'most', 'itself', 'other', 'off', 'is', 's', 'am', 'or', 'who', 'as', 'from'
		, 'him', 'each', 'the', 'themselves', 'until', 'below', 'are', 'we', 'these', 'your'
		, 'his', 'through', 'don', 'nor', 'me', 'were', 'her', 'more', 'himself', 'this'
		, 'down', 'should', 'our', 'their', 'while', 'above', 'both', 'up', 'to', 'ours'
		, 'had', 'she', 'all', 'no', 'when', 'at', 'any', 'before', 'them', 'same', 'and'
		, 'been', 'have', 'in', 'will', 'on', 'does', 'yourselves', 'then', 'that', 'because'
		, 'what', 'over', 'why', 'so', 'can', 'did', 'not', 'now', 'under', 'he', 'you'
		, 'herself', 'has', 'just', 'where', 'too', 'only', 'myself', 'which', 'those', 'i'
		, 'after', 'few', 'whom', 't', 'being', 'if', 'theirs', 'my', 'against', 'a', 'by'
		, 'doing', 'it', 'how', 'further', 'was', 'here', 'than', 'gift', 'card', 'amazon', 'cards')
	AND id <= 50
	
END

GO


