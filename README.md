# Gym

To use function:
```matlab
palestra('data')
```
It will export `Data.pdf` and several figures with:
* mean
* max values
* mean vs max
* linear growth model
* quadratic growth model
* plot in series vs days space
<center>
<img src="https://github.com/mastroalex/gym/blob/main/fig/Squat_figure7.png.webp" alt="example" style="width:400px;"/>
</center>

The function accept data as `.csv` file with the following data structure:

|Data|	SxR	|Serie 1|	…	|Serie n|
|---|---|---|---|---|
|DATA|	SETxREP|	REPxPESO|	…|	REPxPESO|
|gg-mm-aa|	5×5|	5×100|	…|	5×100|

[Extra](https://alessandromastrofini.it/2021/11/03/modello-crescita-sovraccarico-fondamentali/)
