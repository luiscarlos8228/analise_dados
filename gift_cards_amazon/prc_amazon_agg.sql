USE [analise_dados]
GO

/****** Object:  StoredProcedure [dbo].[PRC_AMAZON_AGG]    Script Date: 20/02/2024 19:48:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		LUIS CARLOS
-- Create date: 20/02/2024
-- Description:	INSERIR DADOS EM [dbo].[amazon_gc_agg]
-- =============================================
CREATE PROCEDURE [dbo].[PRC_AMAZON_AGG] 
	
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

BEGIN
	TRUNCATE TABLE analise_dados..amazon_gc_agg
END

BEGIN
	INSERT INTO analise_dados..amazon_gc_agg(
		  ano
		, mes
		, nota
		, votos
		, user_verificado
		, valor
	)

	SELECT
		  YEAR(data_avaliacao) ano
		, MONTH(data_avaliacao) mes
		, nota
		, SUM(votos) votos
		, user_verificado
		, valor

	FROM analise_dados.dbo.amazon_gift_cards
	GROUP BY
		  YEAR(data_avaliacao)
		, MONTH(data_avaliacao)
		, user_verificado
		, valor
		, nota

	ORDER BY ano, mes, nota

END

GO


