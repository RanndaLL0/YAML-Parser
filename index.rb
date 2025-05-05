require './math.rb'

# Verifica a existência do arquivo
caminho_arquivo = if File.exist?('entrada.yaml')
  'entrada.yaml'
elsif File.exist?('entrada.yml')
  'entrada.yml'
else
  conteudo = <<~YAML
    app:
      name: MeuApp
      version: "2.1.0"
      active: true
      description: null

    users:
      - name: Ana
        age: 28
        admin: true
        email: ana@example.com
      - name: Bruno
        age: 34
        admin: false
        email: null

    settings:
      retry_limit: 5
      timeout_seconds: 30.5
      features:
        - login
        - register
        - dashboard
        - analytics

    database:
      host: localhost
      port: 5432
      username: root
      password: "s3cret"
      enabled: false
  YAML
  File.write('entrada.yaml', conteudo)
  'entrada.yaml'
end

entrada = File.read(caminho_arquivo)

class Token
  attr_reader :type, :value

  def initialize(type, value)
    @type = type
    @value = value
  end

  def to_s
    "#{@type}(#{@value})"
  end
end

class Lexer
  def initialize(input)
    @input = input
    @position = 0
  end

  def tokenize
    tokens = []
    while current_char
      case current_char
      when "\n"
        tokens << Token.new(:NEWLINE, "\n")
        advance
      when ":"
        tokens << Token.new(:COLON, ":")
        advance
      when "-"
        tokens << Token.new(:DASH, "-")
        advance
      when '"'
        tokens << string
      when "$"
        tokens << sum
      when /\d/
        tokens << digito
      when /[a-zA-Z]/
        tokens << id_string
      else
        advance
      end
    end
    tokens
  end

  def string
    result = ''
    advance
    while current_char && current_char != '"'
      result += current_char
      advance
    end
    advance
    Token.new(:STRING, result)
  end

  def sum()
    result = ''
    advance
    while current_char && current_char != '$'
      result += current_char
      advance
    end
    advance
    puts result
    Token.new(:SIGN, result)
  end

  def digito()
    result = ''
    while current_char =~ /[\d\.]/
      result += current_char
      advance
    end
    value = result.include?('.') ? result.to_f : result.to_i
    Token.new(:NUMBER, value)
  end

  def id_string()
    resultado = ''
    while current_char =~ /[a-zA-Z_]/
      resultado += current_char
      advance
    end

    case resultado
    when 'true'
      Token.new(:BOOLEAN, 'true')
    when 'false'
      Token.new(:BOOLEAN, 'false')
    when 'null'
      Token.new(:NULL, nil)
    else
      Token.new(:STRING, resultado)
    end
  end

  def current_char
    @input[@position]
  end

  def advance
    @position += 1
  end
end

class Regra
  attr_reader :esquerda, :direita

  def initialize(esquerda, direita)
    @esquerda = esquerda
    @direita = direita
  end

  def to_s
    "#{@esquerda} -> #{@direita.join(' ')}"
  end
end

class Gramatica
  attr_reader :regras, :simbolo_inicial

  def initialize(regras, simbolo_inicial)
    @regras = regras
    @simbolo_inicial = simbolo_inicial
  end
end

class CYKParser
  attr_reader :tabela, :gramatica

  def initialize(gramatica)
    @gramatica = gramatica
    @mathParser = MathParser.new()
  end

  def parse(tokens)
    n = tokens.length
    # Cria uma tabela NxN
    @tabela = Array.new(n) { Array.new(n) { [] } }

    # Passo 1: Analiza os símbolos terminais e adiciona seus
    # não-terminais geradores A->a
    adiciona_terminais(tokens)
    # Passo 2: subir na tabela pelas regras 
    # com não-terminais A->BC
    adiciona_nao_terminais(tokens)
    realizar_operacoes(tokens)

    @tabela
  end

  def aceito?
    @tabela[0][-1].include?(@gramatica.simbolo_inicial)
  end

  def realizar_operacoes(tokens)
    tokens.each_with_index do | token, index |
      if token.type == :SIGN
        resultado, warning = @mathParser.run(token.value)
        puts "#{warning} <- Warning"
        puts "#{token.value} = #{resultado} <- Resultado"
      end
    end
  end

  def adiciona_terminais(tokens)
    arr_simbolos = Array.new(tokens.length) { [] }
    tokens.each_with_index do |token, i|
      @gramatica.regras.each do |regra|
        if terminal?(regra.direita, token.type)
          @tabela[i][i] << regra.esquerda
          arr_simbolos[i] << regra.esquerda
        end
      end
    end

    #imprime_linha(arr_entrada)
    dados = ""
    arr_simbolos.each do |simbolo|
    dados << simbolo.join(",")
    dados << "|"
    end
    puts "Produção da estrutura YAML: #{dados}" 
  end

  def adiciona_nao_terminais(tokens)
      n = tokens.length
      for largura in 1...n
          for inicio in 0...(n - largura)
              fim = inicio + largura
              (inicio...fim).each do |meio|
                  @gramatica.regras.each do |regra|  
                      if match_de_nao_terminais?(inicio, meio, fim, regra)
                      tabela[inicio][fim] << regra.esquerda
                      end
                  end
              end
          end
      end
  end 

  def to_ruby(tokens)
    resultado = "{#{"\n"}"
    tokens.each_with_index do | token,index |
      if token.type == :STRING
         resultado << token.value
      elsif token.type == :COLON
          resultado << "=>"
      elsif token.type == :NEWLINE
          resultado << ",\n"
      elsif token.type == :BOOLEAN
          resultado << token.value
      elsif token.type == :NUMBER
        resultado << token.value
      elsif token.type == :NULL
        resultado << token.value
      elsif token.type == :SIGN
        calculo = @mathParser.run(token.value)[0].to_s
        resultado << calculo
      end
    end
    # resultado << "#{"\n"}}"
  end

  def match_de_nao_terminais?(inicio, meio, fim, regra)
    return false if regra.direita.length < 2
    
    primeira_direita = regra.direita[0]
    segunda_direita = regra.direita[1]
    
    tabela[inicio][meio].include?(primeira_direita) &&
                tabela[meio + 1][fim].include?(segunda_direita)
  end

  def terminal?(direita, token_type)
    direita.length == 1 && direita[0].to_sym == token_type
  end
end

regras = [
  Regra.new('S', ['O', 'Z']),
  Regra.new('S', ['M', 'U']),
  Regra.new('S', ['V', 'A']),
  Regra.new('V', ['STRING']),
  Regra.new('V', ['NUMBER']),
  Regra.new('V', ['BOOLEAN']),
  Regra.new('V', ['NULL']),
  Regra.new('V', ['SIGN']),
  Regra.new('T', ['COLON']),
  Regra.new('N', ['NEWLINE']),
  Regra.new('L', ['DASH']),
  Regra.new('A', ['T', 'V']),
  Regra.new('Z', ['V', 'X']),
  Regra.new('Z', ['N', 'M']),
  Regra.new('Z', ['STRING']),
  Regra.new('Z', ['NUMBER']),
  Regra.new('Z', ['BOOLEAN']),
  Regra.new('Z', ['NULL']),
  Regra.new('Z', ['SIGN']),
  Regra.new('X', ['N', 'S']),
  Regra.new('M', ['L', 'S']),
  Regra.new('M', ['L', 'V']),
  Regra.new('M', ['V', 'G']),
  Regra.new('O', ['V', 'T']),
  Regra.new('U', ['O', 'Z']),
  Regra.new('G', ['T', 'Z'])
]

print("---------entrada---------\n")
print(entrada)
print("\n----------saida----------\n")
gramatica = Gramatica.new(regras, 'S')
lexer = Lexer.new(entrada)
tokens = lexer.tokenize
parser = CYKParser.new(gramatica)
parser.to_ruby(tokens)
parser.parse(tokens)

puts parser.aceito? ? "✅ Aceito" : "❌ Não aceito"