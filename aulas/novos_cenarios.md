# Troca para os cenários novos (SpriteCook)

O que mudou em relação ao que você fez na Aula 1:

1. `assets/cenarios/` agora tem os 13 cenários novos (960x640, pixel art).
   Os antigos (`*_1986`, `*_final`, `parada_onibus`) saíram.
2. `cenas/fases/teste_corredor.tscn` usa o `corredor.png` novo e as colisões
   foram refeitas para a planta nova:

| Colisão | Posição | Tamanho | O que é |
|---|---|---|---|
| ParedeTopo | 480, 111 | 960 x 222 | parede do fundo (portas, quadro) |
| ParedeEsquerda | 10, 320 | 20 x 640 | parede esquerda |
| ParedeDireita | 950, 320 | 20 x 640 | parede direita |
| ParedeBaixoEsquerda | 219, 579 | 438 x 122 | parede de baixo, à esquerda da saída |
| ParedeBaixoDireita | 748, 579 | 424 x 122 | parede de baixo, à direita da saída |
| FundoDaSaida | 487, 600 | 98 x 80 | fim do corredorzinho da saída |
| Banco | 152, 253 | 112 x 30 | banco azul de 4 lugares |
| Bebedouro | 510, 220 | 52 x 20 | bebedouro duplo |
| Extintor | 690, 222 | 20 x 16 | extintor |
| Escada | 902, 311 | 80 x 178 | escada à direita |

3. A Bia começa em (487, 470), perto da saída. O zumbido da lâmpada foi para (270, 240).
4. `bia.gd` está na versão suave (aceleração 900, ciclo de 4 passos, ritmos 10/16/6),
   com interpolação de física ligada e a câmera em modo Physics.
