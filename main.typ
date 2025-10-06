#import "@preview/elsearticle:1.0.0": *
#import  "@preview/dashy-todo:0.1.2": todo


#let todo-inline = todo.with(position: "inline", stroke: (paint: red, thickness: 4pt, cap: "round"))

#set math.cases(gap: 0.8em)
#set terms(separator: [ --- ], tight:false)

#show terms: it => {
  it.children
    .map(child => [
      #grid(
        columns: (2fr, 12fr),
        align: (right, left),
        column-gutter: 1em,
        [#strong[#child.term ---     ]], [#child.description]
      )
      ])
    .join()
}
#show: elsearticle.with(
  title: [Implementación de modelo de neurona \
  _Leaky integrate-and-fire_ mediante VCSEL],
  authors: (
    (
      name: "María Luz Stewart Harris",
      affiliation: "Instituto Balseiro",
      // corr: "maria.stewart@ib.edu.ar",
    ),
  ),
  // journal: "Name of the Journal",
  // abstract: abstract,
  // keywords: ("keyword 1", "keyword 2"),
  format: "review",
  // line-numbering: true,
)
#todo-inline[Cambiar de Figure a figura]
= Introducción

#todo-inline([
  Motivación de por que querria una neurona laser:
  - Quiero tener redes neuronales cada vez mas grandes pero tengo limitacion en la capacidad de computo
  - Ventajas de hw neuromorfico comparado con CPUs y GPUs
  - Ejemplo HW neuromorfico actual? opcional (ponele TrueNorth de IBM)
  - *Como podría mejorarse con fotonica*])

= Todas las cosas de redes neuronales

== Spiking Neural Networks (SNN)

#cite(<Maass1997>)

#todo-inline([
  - neuronas se transmiten información a traves de señales elecricas. Estas señales son analogicas y tienen pulsos muy marcados.
  - codificacion de informacion en las neuronas esta dada por la posicion temporal donde se generan los pulsos (no por la forma del pulso, ni por la forma de la señal cuando no hay pulso)
  - Las SNN son redes neuronales artificiales en donde las neuronas solo transmiten pulsos en tiempo continuo (es decir, son analogicos en tiempo y digitales en amplitud
])


== Modelo de neurona _Leaky integrate-and-fire_


#cite(<Abbott1999>)

#todo-inline(["studies
of function do not necessarily require an understanding of mechanism" => si anda anda, por mas que no modele todos los procesos biologicos que causen ese comportamiento. Es decir, es "a caja negra" (de hecho cuando se desarrollo el modelo ni siquiera se sabia bien como funcionaba una neurona por dentro. El primer modelo matematico de eso vino muchos años despues con HH. Puede ser una buena nota al pie? Un curiosidato?)])


#todo-inline("Como es el modelo leaky integrate and fire?")



= Implementación del modelo Leaky integrate-and-fire en láser VCSEL

Un sistema que implemente un modelo de neurona LIF debe tener las siguientes propiedades:

+ Una variable $s$, considerada el estado de la neurona, que funcione como integrador con pérdidas de la entrada al sistema.
+ Comparación de $s$ con un valor umbral.
+ Resititución de $s$ a un valor inicial luego de que alcance el valor umbral.
+ Generación de un pulso cuando $s$ alcance el valor umbral.

Las cuatro propiedades pueden conseguirse con un láser basado en el modelo Yamada de Q-switching pasivo #cite(<Yamada1993>). Éste describe un láser formado por una región activa (región 1) y una región con absorción saturable (región 2). La figura #ref(<fig:lasernahmias>) muestra un esquemático de una implementación en un VCSEL #cite(<Nahmias2013>).

Las ventajas de utilizar un VCSEL incluyen:
 + Pueden fabricarse de forma integrada ocupando poca área.
 + Pueden fabricarse en gran cantidad de forma interconectada.
Estas características favorecen su escalabilidad, potencialmente permitiendo generar redes con grandes cantidades de neuronas interconectadas. #todo([Esto queda medio colgado, quizas es mejor ponerlo al final o en otro lado.])

#figure(
  square(fill: red),
  caption: [Esquemático de un VCSEL basado en el modelo Yamada que implementa el modelo de neurona LIF.]
) <fig:lasernahmias>


El sistema está descrito por un sistema de 3 ecuaciones diferenciales cuyas variables son la concentración del número de fotones $S$ y las densidades de electrones en el medio activo y en el absorbente saturable ($N_1$ y $N_2$ respectivamente): 
// Ecuaciones Yamada, no poner
// $
//   cases(
//     (dif S)/(dif t) = [ xi_1 underbracket(a_1 (N_1 - N_(g 1)), ~G_1) + xi_2 underbracket(a_2 (N_2 - N_(g 2)), ~G_2) - G_(t h)]S + C (N_1 V_1)/tau_S,
//     (dif N_1)/(dif t) = -(xi_1)/V_1 underbracket(a_1 (N_1 - N_(g 1)), ~G_1)S - N_1/tau_S - (N_1 - N_2)/T_(1 2) + I/(e V_1),
//     (dif N_2)/(dif t) = -(xi_2)/V_2 underbracket(a_2 (N_2 - N_(g 2)), ~G_2)S - N_2/tau_S - (N_2 - N_1)/T_(2 1)
//   )

$
  cases(
    (dif N_(p h))/(dif t) = [ Gamma_a underbracket(g_a (n_a - n_(a 0)), ~G_a) + Gamma_2 underbracket(g_s (n_s - n_(s 0)), ~G_s) - 1/tau_(p h)]N_(p h) +  V_1 beta B_r n_a^2,

    (dif n_a)/(dif t) = -(Gamma_1)/V_a underbracket(g_a (n_a - n_(a 0)), ~G_a)(N_(p h)-phi.alt(t)) - n_a/tau_a + (I_a+i_e (t))/(e V_a),

    (dif n_s)/(dif t) = -(Gamma_s)/V_s underbracket(g_s (n_s - n_(s 0)), ~G_s)N_(p h) - n_s/tau_s + I_s/(e V_s)
  )
$<eq:nahmias_feas>

donde

/ $g_(a,s)$: Constante de proporcionalidad entre el coeficiente de ganancia y la densidad de electrones en la región $(a,s)$.
/ $Gamma_(a,s)$: Coeficiente de confinamiento de la región $(a,s)$.
/ $n_((a,s) 0)$: Densidad de electrones umbral a partir de la cual la ganancia de la region (a,s) es positiva.
/ $tau_(p h)$: Vida media de un fotón.
/ $tau_(a, s)$: Vida media del estado superior en la región $(a,s)$.
/ $C$: Coeficiente de emisión espontánea. #todo([Corregir])
/ $V_(a, s)$: Volumen de la región (a,s).
/ $G_(a,s)$: Ganancia de la región (a,s). Se aproxima con una serie de Taylor de primer orden tal que  $G_(a,s) ~ g_(a,s) (n_(a,s) - n_((a,s)0))$
/ $I_(a,s)$: corriente de bombeo constante en la región (a,s).
/ $i_e (t)$: corriente de bombeo variable en la región a.


Aplicando el cambio de variable de las ecuaciones #ref(<eq:cambio_variable_nahmias>) se obtiene la descripción equivalente del sistema de la ecuaciones #ref(<eq:nahmias_bonitas>)

$
  cases(
    u &= t/tau_(p h),
    G(u)&=tau_(p h) Gamma_a g_a (n_a (t)-n_(a 0)) &= tau_(p h) Gamma_a g_a (n_a (u tau_(p h))-n_(a 0)),
    Q(u)&=tau_(p h) Gamma_s g_s (n_(s 0)-n_s (t)) &= tau_(p h) Gamma_s g_s (n_(s 0)-n_s (u tau_(p h))),
    I(u) &= (tau_a Gamma_a g_a) /V_a N_(p h)(t) &= (tau_a Gamma_a g_a) /V_a N_(p h)(u tau_(p h))
  )
$ <eq:cambio_variable_nahmias>

$
  cases(
    dot(I)(u) &=gamma_I [G(u) - Q(u) -1] I(t) + epsilon.alt f(u),
    dot(G)(u)&=gamma_G [A-G(u) - G(u)I(u)],
    dot(Q)(u)&=gamma_Q [B-Q(u) - Q(u)I(u)],
  )
$ <eq:nahmias_bonitas>

donde:
#nonumeq(
$
  G &prop "Ganancia de la región "a"." \
  Q &prop "Pérdidas de la región "s"." \
  I &prop "Potencia de salida del láser."
$
)

#todo-inline([
  - #strike([Ecuaciones originales de #cite(<Nahmias2013>)])
  - Cambio de variable a sistema G, I, Q, 
    - explicar el significado mas o menos de las tres variables referencias
      - $I prop P$ (o a cantidad de fotones en la cavidad, es lo mismo?)
      - $G prop (n_a - n_(a 0))$
      - $Q prop (n_(s 0) - n_s)$
    - referenciar al anexo donde esta hecho el cambio de variable en mas detalle si es que tengo tiempo
  - Paso a paso de como se genera el pulso ("explicar la ecuacion diferencial en palabras" ponele)
  - Poner la ecuacion de G e I simplificada que es identica a la de leaky integrate and fire (incluyendo el pulso en I y el reset de G)
  - Describir explicitamente como es que cumple las condiciones de excitabilidad mencionadas anteriormente
  - Grafico basico de como manda un unico pulso en I y como se resetea G y Q
])



#todo-inline([ Mostrar al menos uno de los resultados avanzados del paper, tipo el de reconocimiento de patrones])

#todo-inline([repasar los apuntes de clase de los VCSEL. En algun lado mencionar el potencial de los VCSEL de hacerse integrados y poder tener muchas neuronas en un mismo chip integrado])

#todo-inline([por que absorbente saturable?])


#show: appendix

= Equivalencia entre descripciones matemáticas

$
  cases(
  (dif n_a)/(dif t) &= -Gamma_a g_a (n_a - n_(a 0))(N_(p h)-phi.alt(t))/V_a-n_a/tau_a + (I_a+i_e (t))/(e V_a),
  (dif n_s)/(dif t) &= -Gamma_s g_s (n_s - n_(s 0))(N_(p h)/V_s)-n_s/tau_S + I_s/(e V_s),
  (dif N_(p h))/(dif t) &= (Gamma_a g_a (n_a - n_(a 0)) + Gamma_s g_s (n_s - n_(s 0)) -1/tau_(p h)) N_(p h) + V_a beta B_r n_a^2
  ) 
$ <eq:anexo_a_nahmias_original>

Se aplica un cambio de variables a la ecuación #ref(<eq:anexo_a_nahmias_original>):



Reemplazando #ref(<eq:cambio_variable_nahmias>) en #ref(<eq:anexo_a_nahmias_original>):

#todo-inline("TERMINAR EL ANEXO O BORRAR")


#bibliography("refs.bib")