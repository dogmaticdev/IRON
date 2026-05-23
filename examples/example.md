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
This is the code:
```
$t4-
? turn &turn &then

    $turn <
    ? 8bit &8bit &next
        $8bit = mov = byte > , ^ .

    $next
    ? byte &byte &next
        $byte = mov = byte > , ^ .

    $next
    ? 16bit &16bit &next
        $16bit = mov = word > , ^ .

    $next
    ? word &word &next
        $word = mov = word > , ^ .

    $next
    ? 32bit &32bit &next
        $32bit = mov = dword > , ^ .

    $next
    ? dword &dword &next
        $dword = mov = dword > , ^ .

    $next
    ? 64bit &64bit &next
        $64bit = mov = qword > , ^ .

    $next
    ? qword &qword &next
        $qword = mov = qword > , ^ .

    $next
    ? 128bit &128bit &next

        $128bit (
        ? float &float &next1

            $float < +
            ? even &even &next2

                $even <
                ? replicate &replicate !
                    $replicate = movsldup ) , > .

            $next2
            ? odd &odd &float

                $odd <
                ? replicate &replicate !
                    $replicate = movshdup ) , > .

            $float = movups ) , > .

        $next1
        ? double &double &next1

            $double <
            ? float &float !

                $float ` + (
                ? replicate &replicate &float
                    $replicate = movddup > , ) .

                $float = movupd > , ~ ^ .

        $next1
        ? aligned &aligned &basic

            $aligned <
            ? float &float &next2
                $float = movaps > , ^ .

            $next2
            ? double &double &aligned

                $double (
                ? float &float !
                    $float = movapd ) , ^ .

            $aligned = movdqa ) , ^ .

        $basic = movdqu > , ^ .

    $next
    ? 256bit &256bit &next

        $256bit (
        ? float &float &next1

            $float < +
            ? even &even &next2

                $even <
                ? replicate &replicate !
                    $replicate = vmovsldup ) , > .

            $next2
            ? odd &odd &float

                $odd <
                ? replicate &replicate !
                    $replicate = vmovshdup ) , > .

            $float = vmovups ) , > .

        $next1
        ? double &double &next1

            $double <
            ? float &float !

                $float ` + (
                ? replicate &replicate &float

                    $replicate = vmovddup > , ) .

                    $float = vmovupd > , ~ ^ .

        $next1
        ? aligned &aligned &basic

            $aligned <
            ? float &float &next2
                $float = vmovaps > , ^ .

            $next2
            ? double &double &aligned

                $double (
                ? float &float !
                    $float = vmovapd ) , ^ .

            $aligned = vmovdqa ) , ^ .

        $basic = vmovdqu > , ^ .

    $next
    ? 512bit &512bit !

        $512bit (
        ? float &float &next1

            $float < +
            ? even &even &next2

                $even <
                ? replicate &replicate !
                    $replicate = vmovsldup ) , > .

            $next2
            ? odd &odd &float

                $odd <
                ? replicate &replicate !
                    $replicate = vmovshdup ) , > .

            $float = vmovups ) , > .

        $next1
        ? double &double &next1

            $double <
            ? float &float !

                $float ` + (
                ? replicate &replicate &float
                    $replicate = vmovddup > , ) .

                $float = vmovupd > , ~ ^ .

        $next1
        ? aligned &aligned &basic

            $aligned <
            ? float &float &next2
                $float = vmovaps > , ^ .

            $next2
            ? double &double &aligned

                $double (
                ? float &float !
                    $float = vmovapd ) , ^ .

            $aligned = vmovdqa ) , ^ .

        $basic = vmovdqu > , ^ .

    $then
```
