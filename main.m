pkg load image % solo para correr en octave

clc; clear all variables;

% FUNCIONES -----------------------------------------------
function p = P(N, nG)
    p = nG / N;
end

function h = H(minimum, maximum, N, nG)
%{
    se define  las entropías del fondo y del objeto usando la entropía 
    de Shannon, paramétricamente dependiente del valor umbral t
%}
    h = 0;
    for i=minimum:maximum
       h = h + ( P(N, nG(i, 1))/log(P(N, nG(i, 1))) );
    endfor
    h = h * -1;
end

function filtrado = Filter(imagen, N)
    [y, x] = size(imagen);
    filtrado = zeros(y, x);
end
% FUNCIONES -----------------------------------------------


%{
    como primer paso, se lee la imagen y se convierte en escala de grises
%}
imagen = rgb2gray(imread("pesos.jpg"));
figure(1); imshow(imagen); % mostramos la imagen en gris
%{
    como segundo paso, sacamos el umbral maximo de la imagen, para poder
    convertir la imagen en escala de grises en blanco y negro

    para eso se necesita sacar la probabilidad de gris en un pixel,
    se utiliza la formula:
    p(g) = nG/N
    siedo:
        nG, la cantidad de veces que se repite la informacion de un pixel en g
        N, el total de pixeles de la imagen
        g, el valor del histograma que va de 0 a 256
%}

% conseguimos los pixeles en alto y ancho
[y, x] = size(imagen); 

% lo multiplicamos para obtener el numero total de pixeles
N = x * y; 

% nG contiene una matriz 256x1
[nG, sizer] = imhist(imagen);
% la varibale sizer tiene el valor minimo y maximo del histograma 
min_hist = min(sizer);
max_hist = max(sizer);

figure(2); imhist(imagen); % mostramos el histograma

%{
   la variable t es el valor del histrograma donde se genera el cambio
   drastico de informacion de la escala de grises.
   con base al histograma se elige este valor, en medio del valle de informacion.
%}

t = 245; % para la obtencion de esta variable usaremos un algoritmo que detecte el cambio en el histograma

%{
    hT es la suma de las entripias de la imagen, la diferencia de hT con 1, es
    el umbral aplicable a la imagen
%}
hT = H(min_hist+1, t, N, nG) + H(t+1, max_hist, N, nG); % valor del umbral aplicable

% la funcion im2bw devuelve la imagen binaria, con el umbral que calculamos
imagen_umbralizada = im2bw(imagen, 1-hT);

figure(3); imshow(imagen_umbralizada);

%{
    el tercer paso es negar la informacion umbralizada, y filtrar los puntos sueltos
    dentro de la imagen, para que solo queden circulos vacios
%}

% convertimos todos los 1 a 0, y 0 a 1
negada = not(imagen_umbralizada);
figure(4); imshow(negada);

% filtramos la imagen y la convolucionamos con la negada
filtro = Filter(negada, 5);
filtrada = conv2(filtro, negada);
figure(5); imshow(filtrada);

pause();