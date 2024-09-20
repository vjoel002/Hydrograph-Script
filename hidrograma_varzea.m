%   Codigo de Geracao de Hidrograma de Fluxo
%
%   Feito e Testado em GNU Octave 6.2.0
%
%     Data:   30/06/2021  (Versao 3)
%
%   Referencia da "forma/tipo" do hidrograma:
%
%     BARFIELD, B. J., WARNER, R. C. e HAAN, C. T., 1981.
%
%     Applied hydrology and sedimentology for disturbed areas, Oklahoma Technical Press

function hidrograma
% Limpando as Variaveis Anteriores e Fechando Graficos Anteriores
clear all
close all

% Parametros do Hidrograma de Fluxo
% Valor k Ajustado p/ dar o Volume Igual ao Volume Extravasado
Qp = 659.88;             % Vazao de Pico, em metros cubicos por segundo
tpmin = 20.0;           % Tempo de Pico, em minutos
k = 4.09968183;             % Para o Volume Util de Pedreira
%k = 0.211788;           % Para o Volume Util de Duas Pontes


% Nao Alterar Esse Valor
tpseg = tpmin * 60.0;    % Tempo de Pico, em minutos

% Criterio de Parada para Determinar o Tempo Base "Tb"
% A Construcao do Hidrograma Termina se a Vazao for Menor que "Qstop" m3/s
Qstop = 1.0;

% Tempo Inicial
t = 0.0;

% Passo de Tempo (em Segundos)
dt = 0.1;
tsave = floor(60.0/dt); % Para Salvar a Cada Minuto

% Arquivo para Escrever o Hidrograma Completo (Tempo e Vazao)
fid = fopen('hidrograma_tempo_vazao.dat', 'w');

% Variavel para Acumular a Vazao no Tempo
Volume = 0.0;
Qlast = 0.0;

% Hidrograma: tempo (min), vazao (m3/s)
count = 0.0;
it = 0;
fprintf(fid, '%3d %1.8e\n', 0, 0.0);

while (1)
Q = Qp*((t/tpseg)*exp(1.0 - (t/tpseg)))^k;
tminutos = t/60.0;
  if (t > tpseg)
    if (Q < Qstop)
        fprintf(fid, '%4d %1.8e', tlast+1, 0.0);
        fflush(fid);
        count++;
        break
    end
  end
  if (it == tsave)
  tlast = tminutos;
  fprintf(fid, '%3d %1.8e\n', tminutos, Q);
  fflush(fid);
  % Integrando Usando Trapezios; o Fator "60.0" converte 1 minuto para 60 segundos
  Volume = Volume + 60.0*0.5*(Qlast+Q);
  Qlast = Q;
  count++;
  it = 0;
  end
t = t + dt;
it++;
end
fclose(fid);

fid = fopen('hidrograma_tempo_vazao.dat','r');
hidrog = fscanf(fid,'%d%f\n',[2,count+1])';
fclose(fid);

% Arquivo Excel para "Colar" o Hidrograma no HEC-RAS
% (Tempo em MINUTOS e Vazao em Metros Cubicos por SEGUNDO!)
arq = fopen('hidrograma_vazao.csv','w+');
for it=1:count+1
fprintf(arq,'%1.8f\n',hidrog(it,2));
end
fclose(arq);

set(gca, 'fontsize', 22);
box on
xlabel('t (min)');
ylabel('Q (m3/s)');
hold on

color = [0.21, 0.47, 0.87];
plot(hidrog(:,1),hidrog(:,2), 'color', color, 'linewidth',1.5);
pointsize = 30.0;
scatter(hidrog(:,1),hidrog(:,2), pointsize, color, "c", "filled");
legend("boxoff");
legend({["V = ",num2str(Volume,"%1.8E")," m3"]},"fontsize",22);
grid on

hold off
end
