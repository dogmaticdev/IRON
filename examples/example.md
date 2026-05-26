# Info
Using the template txt and this code directly below it i am able to input this source code:
```
turn 128bit double float xmm1 into replicate of xmm2
turn 128bit double float xmm1 into xmm2
turn 128bit float xmm1 into even replicate xmm2
turn 128bit xmm1 into xmm2
turn 128bit aligned xmm1 into xmm2
```
And have IRON output this:
```
movddup xmm1, xmm2
movupd xmm1, xmm2
movsldup xmm1, xmm2
movdqu xmm1, xmm2
movdqa xmm1, xmm2
```
It was able to compile this source code to assembly in 55000 nano seconds.
This is the code:
```
    $128bit < * `
    ? float &float &next2

        $float < * *
        ? even &even &next3

            $even *
            ? replicate &replicate !
                $replicate = movsldup > , ^ .

        $next3
        ? odd &odd &float

            $odd *
            ? replicate &replicate !
                $replicate = movshdup > , ^ .

        $float ~ = movups ^ , ^ .

    $next2
    ? double &double &next2

        $double * `
        ? float &float !

            $float < * *
            ? replicate &replicate &float
                $replicate = movddup > , ^ .

            $float ~ = movupd ^ , ^ .

    $next2
    ? aligned &aligned &basic

        $aligned *
        ? float &float &next3
            $float = movaps ^ , ^ .

        $next3 *
        ? double &double &aligned

            $double *
            ? float &float !
                $float = movapd ^ , ^ .

        $aligned ~ = movdqa ^ , ^ .

    $basic = movdqu > , ^ .
```
