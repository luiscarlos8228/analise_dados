from sqlalchemy import create_engine

# classe com funcoes para utilizar nos projetos
class funcoes(object):
    def __init__(self, servidor, banco, driver):
        self.servidor = servidor
        self.banco = banco
        self.driver = driver
        self.engine, self.conn = self.conectar_sql()       

    # função para conexão com o sql
    def conectar_sql(self):
        conn_str = f'mssql+pyodbc://{self.servidor}/{self.banco}?driver={self.driver}&Trusted_Connection=yes'
        engine = create_engine(conn_str, echo=False)
        return engine, engine.connect()
    
    # função para subir dados no sql
    def subir_dados(self, df, tabela, schema='dbo', modo='append', index=False):        
        df.to_sql(
            name=tabela,
            con=self.engine,
            schema=schema,
            if_exists=modo,
            index=index
        )

    # função para extrair o valor do gift card da coluna valor
    def extrair_numero(self, d):
        if isinstance(d, dict) and 'Gift Amount:' in d:
            return int(d['Gift Amount:'].strip())
        else:
            return None

    def fechar_conexao(self):
        self.engine.dispose()

    def query_sql(self, query):
        connection = self.engine.raw_connection()
        try:
            cursor = connection.cursor()
            cursor.execute(query)
            connection.commit()
        finally:
            connection.close()
        
