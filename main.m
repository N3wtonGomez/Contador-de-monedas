pkg load image % solo para correr en octave

clc; clear all variables;

function p = P(N, nG)
    p = nG / N;
end

function h = H(minimum, maximum, N, nG)
    h = 0;
    for i=minimum:maximum
       h = h + ( P(N, nG(i, 1))/log(P(N, nG(i, 1))) );
    endfor
    h = h * -1;
end

function filled = Filter(img)
    
    conn = conndef(ndims(img), "minimal");

    mask = imcomplement(img);

    marker = no_borde(mask, conn, false);

    filled = imreconstruct(marker, mask, conn);
    filled = imcomplement(filled);
endfunction


function marker = no_borde(img, conn, val)
    sz = size(img);

    nonborder_idx = repmat({":"}, ndims (img), 1);

    conn_idx_tmp = repmat({":"}, ndims (conn), 1);
    for dim = 1:ndims(conn)
        conn_idx = conn_idx_tmp;
        ## Because connectivity is symmetric by definition, we only need
        ## to check the first slice of that dimension.
        conn_idx{dim} = [1];
        if (any(conn(conn_idx{:})(:)))
        nonborder_idx{dim} = 2:(sz(dim) -1);
        endif
    endfor

    marker = img;
    marker(nonborder_idx{:}) = false;
end


imagen = rgb2gray(imread("pesos.jpeg"));
figure(1); imshow(imagen);

[y, x] = size(imagen); 

N = x * y; 

[nG, sizer] = imhist(imagen);
min_hist = min(sizer);
max_hist = max(sizer);

figure(2); imhist(imagen);

t = 120;
hT = H(min_hist+1, t, N, nG) + H(t+1, max_hist, N, nG);

imagen_umbralizada = im2bw(imagen, hT);
figure(3); imshow(imagen_umbralizada);

negada = not(imagen_umbralizada);
figure(4); imshow(negada);

SE = strel('disk', 20, 0);
filtrada = imdilate(negada, SE);
llenada = Filter(filtrada);

figure(5); imshow(llenada);

bw = bwlabel(llenada);
cantidad = max(max(bw));
fprintf("La cantidad de monedas en la imagen son: %i ", cantidad);

pause();