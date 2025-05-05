class Arvore
  attr_reader :simbolo, :esquerda, :direita, :valor

  def initialize(simbolo, esquerda=nil,direita=nil,valor=nil)
    @simbolo = simbolo
    @esquerda = esquerda
    @direita = direita
    @valor = valor
  end

  def to_s
    if valor
      valor.to_s
    elsif direita
      "[#{@simbolo}, #{@esquerda}, #{@direita}]"
    else
      "[#{@simbolo}, #{@esquerda}]"
    end
  end
end

class TokenMath
  attr_reader :type, :value

  def initialize(type, value)
    @type = type
    @value = value
  end

  def to_s
    "#{@type}(#{@value})"
  end
end

class LexerMath
  def initialize(input)
    @input = input
    @position = 0
  end

  def tokenize
    tokens = []
    while current_char
      case current_char
      when "+"
        tokens << TokenMath.new(:SUM, "+")
        advance
      when "-"
        tokens << TokenMath.new(:SUB, "-")
        advance
      when "^"
        tokens << TokenMath.new(:EXP, "^")
        advance
      when "*"
        tokens << TokenMath.new(:MULT, "*")
        advance
      when "/"
        tokens << TokenMath.new(:DIV, "/")
        advance
      when "("
        tokens << TokenMath.new(:P_ESQ, "(")
        advance
      when ")"
        tokens << TokenMath.new(:P_DIR, ")")
        advance
      when /[0-9]/
        tokens << digitos
      else
        advance
      end
    end
    tokens
  end

  def digitos()
    result = ''
    while current_char =~ /[\d\.]/
      result += current_char
      advance
    end
    value = result.to_f
    TokenMath.new(:DIGITOS, value)
  end

  def current_char
    @input[@position]
  end

  def advance
    @position += 1
  end
end

class RegraMath
  attr_reader :esquerda, :direita

  def initialize(esquerda, direita)
    @esquerda = esquerda
    @direita = direita
  end

  def to_s
    "#{@esquerda} -> #{@direita.join(' ')}"
  end
end

class MathGramatica
  attr_reader :regras, :simbolo_inicial

  def initialize(simbolo_inicial)
    @regras = [
      RegraMath.new('S',['S' , 'Z']),
      RegraMath.new('S',['S' , 'W']),
      RegraMath.new('S',['A' , 'Y']),
      RegraMath.new('S',['A' , 'X']),
      RegraMath.new('S',['N' , 'U']),
      RegraMath.new('S',['DIGITOS']),
      RegraMath.new('S',['O', 'N']),
      RegraMath.new('S',['E', 'Q']),
      RegraMath.new('A',['A', 'Y']),
      RegraMath.new('A',['A', 'X']),
      RegraMath.new('A',['N', 'U']),
      RegraMath.new('A',['DIGITOS']),
      RegraMath.new('A',['O', 'N']),
      RegraMath.new('A',['E', 'A']),
      RegraMath.new('A',['E', 'Q']),
      RegraMath.new('B',['N', 'U']),
      RegraMath.new('B',['DIGITOS']),
      RegraMath.new('B',['O', 'N']),
      RegraMath.new('B',['E', 'Q']),
      RegraMath.new('E',['J', 'S']),
      RegraMath.new('E',['J', 'A']),
      RegraMath.new('E',['J', 'B']),
      RegraMath.new('Z',['L', 'A']),
      RegraMath.new('Z',['L', 'N']),
      RegraMath.new('W',['O', 'A']),
      RegraMath.new('W',['O', 'N']),
      RegraMath.new('Y',['F', 'B']),
      RegraMath.new('Y',['F', 'N']),
      RegraMath.new('X',['P', 'B']),
      RegraMath.new('X',['P', 'N']),
      RegraMath.new('U',['H', 'A']),
      RegraMath.new('U',['H', 'B']),
      RegraMath.new('U',['H', 'S']),
      RegraMath.new('O',['SUB']),
      RegraMath.new('L',['SUM']),
      RegraMath.new('F',['MULT']),
      RegraMath.new('P',['DIV']),
      RegraMath.new('H',['EXP']),
      RegraMath.new('N',['DIGITOS']),
      RegraMath.new('J',['P_ESQ']),
      RegraMath.new('Q',['P_DIR']),
    ]
    @simbolo_inicial = simbolo_inicial
  end
end

class MathParser
  attr_reader :tabela, :gramatica, :raiz

  def initialize(raiz=nil)
    @gramatica = MathGramatica.new('S')
    @raiz = raiz
  end

  def parse(tokens,entrada)
    n = tokens.length
    # Cria uma tabela NxN
    @tabela = Array.new(n) { Array.new(n) { [] } }

    # Passo 1: Analiza os símbolos terminais e adiciona seus
    # não-terminais geradores A->a
    adiciona_terminais(tokens)
    # Passo 2: subir na tabela pelas regras 
    # com não-terminais A->BC
    adiciona_nao_terminais(tokens)
    realiza_soma(entrada)

    @raiz = @tabela[0][n - 1].find { |n| n.simbolo == @gramatica.simbolo_inicial}

    # @tabela.each_with_index do |token, index|
    #   puts "-----elementos na linha #{index}------"
    #   k = ''
    #   @tabela[index].each_with_index do | t, j |
    #     k << "#{t.join(',')} |"
    #   end
    #   puts k
    # end

    @tabela
  end

  def realiza_soma(entrada)
    terms = entrada.split(' ')
    tree = []
  end

  def aceito?
    return !@raiz.nil?
  end

  def adiciona_terminais(tokens)
    arr_simbolos = Array.new(tokens.length) { [] }

    tokens.each_with_index do |token, i|
      @gramatica.regras.each do |regra|
        if terminal?(regra.direita, token.type)
          @tabela[i][i] << Arvore.new(regra.esquerda, nil, nil, token.value)
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
    puts "Produção do tipo Calculo: #{dados}\n" 
  end

  def adiciona_nao_terminais(tokens)
      n = tokens.length
      for largura in 1...n
          for inicio in 0...(n - largura)
              fim = inicio + largura
              (inicio...fim).each do |meio|
                  @gramatica.regras.each do |regra|
                      next unless regra.direita.length == 2
                      @tabela[inicio][meio].each do |esq|
                        @tabela[meio + 1][fim].each do |dir|
                          if esq.simbolo == regra.direita[0] && dir.simbolo == regra.direita[1]
                            @tabela[inicio][fim] << Arvore.new(regra.esquerda,esq,dir)
                          end
                        end
                      end
                    end
                end
            end
        end
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

  def traduz_operacao(no)
    if no.valor != nil
      return no.valor
    end
    
    if ['S', 'A', 'B'].include?(no.simbolo)
      if no.direita
        case no.direita.simbolo
        when 'Z'
          return ["soma", traduz_operacao(no.esquerda), extrair_operando(no.direita)]
        when 'W'
          return ["subtracao", traduz_operacao(no.esquerda), extrair_operando(no.direita)]
        when 'Y'
          return ["multiplicacao", traduz_operacao(no.esquerda), extrair_operando(no.direita)]
        when 'X'
          return ["divisao", traduz_operacao(no.esquerda), extrair_operando(no.direita)]
        when 'U'
          return ["exponenciacao", traduz_operacao(no.esquerda), extrair_operando(no.direita)]
        when 'E'
          return ["parenteses", traduz_operacao(no.esquerda), extrair_operando(no.direita)]
        end
      end
    end

    if no.simbolo == 'N'
      return traduz_operacao(no.esquerda) if no.esquerda
      return no.valor if no.valor
    end
    if ['Z', 'W', 'Y', 'X', 'U','E'].include?(no.simbolo)
      return extrair_operando(no)
    end
    if no.esquerda
      return traduz_operacao(no.esquerda)
    elsif no.direita
      return traduz_operacao(no.direita)
    end
    return nil
  end

  def realizar_operacao(expressao)

    if !expressao.is_a?(Array)
      return expressao
    end

    operador = expressao[0]
    esquerda = expressao[1]
    direita = expressao[2]

    case operador
      when "divisao"
          return realizar_operacao(esquerda) / realizar_operacao(direita)
      when "multiplicacao"
          return realizar_operacao(esquerda) * realizar_operacao(direita)
      when "exponenciacao"
          return realizar_operacao(esquerda) ** realizar_operacao(direita)
      when "subtracao"
          return realizar_operacao(esquerda) - realizar_operacao(direita)
      when "soma"
          return realizar_operacao(esquerda) + realizar_operacao(direita)
      end
  end

  def run(entrada)

    lexer = LexerMath.new(entrada)
    tokens = lexer.tokenize
    parse(tokens,entrada)

    if aceito?
      operacao_traduzida = traduz_operacao(raiz) 
      resultado,warning = realizar_operacao(operacao_traduzida), operacao_traduzida
      puts "#{warning} <- Warning"
      puts "#{entrada} = #{resultado} <- Resultado"
    else
      puts "Expressão rejeitada."
    end
  end

    def extrair_operando(no)
      if no.simbolo == 'Z'
        return traduz_operacao(no.direita)
      elsif no.simbolo == 'W'
        return traduz_operacao(no.direita)
      elsif no.simbolo == 'Y'
        return traduz_operacao(no.direita)
      elsif no.simbolo == 'X'
        return traduz_operacao(no.direita)
      elsif no.simbolo == 'U'
        return traduz_operacao(no.direita)
      elsif no.direita
        return traduz_operacao(no.direita)
      elsif no.esquerda
        return traduz_operacao(no.esquerda)
      end
      return nil
    end
end

# def run_teste()
#   print("---------entrada---------\n")
#   print(entrada)
#   print("\n----------saida----------\n")
#   entrada = "20 ^ 2 / 3.5"
#   parser = MathParser.new()
#   parser.run(entrada)

#   puts parser.aceito? ? "Aceito" : "Não aceito"

#   if parser.aceito?
#     puts "\nExpressão aceita pela gramática."
#     puts "\nÁrvore de operações:"
#     operacao_traduzida = parser.traduz_operacao(parser.raiz) 
#     puts operacao_traduzida.inspect
#     puts "\nResultado da operação: %.2f" % parser.realizar_operacao(operacao_traduzida)
#   else
#     puts "Expressão rejeitada."
#   end
# end