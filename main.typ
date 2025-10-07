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
  numcol: 1,
  // journal: "Name of the Journal",
  // abstract: abstract,
  // keywords: ("keyword 1", "keyword 2"),
  format: "review",
  // line-numbering: true,
)
#outline()

#todo-inline[Cambiar de Figure a figura]
= Introducción

#todo-inline([
  Motivación de por que querria una neurona laser:
  - Quiero tener redes neuronales cada vez mas grandes pero tengo limitacion en la capacidad de computo
  - Ventajas de hw neuromorfico comparado con CPUs y GPUs
  - Ejemplo HW neuromorfico actual? opcional (ponele TrueNorth de IBM)
  - *Como podría mejorarse con fotonica*])

= Modelos neuronales

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

$
  cases(
    dot(s)(t) &= 1/tau_s [s_("rest")-s(t)] + I(t),
    V(t) &= sum_i^oo delta(t-t_f_i),
    s(t_f_i) &<-- s_("reset") ,
  )\
  "Siendo " t_f_i = t slash.big s(t) >= s_(t h)
$ <eq:LIF>

#figure(
  square(fill: red),
  caption: [Modelo de neurona _leaky integrate-and-fire_ (LIF).]
)



= Implementación del modelo de neurona LIF en láser VCSEL

Un sistema que implemente un modelo de neurona LIF debe cumplir las siguientes condiciones, llamadas _condiciones de excitabilidad_:

+ Una variable $s,$ considerada el estado de la neurona, que funcione como integrador con pérdidas de la entrada al sistema.
+ Comparación de $s$ con un valor umbral.
+ Generación de un pulso cuando $s$ alcance el valor umbral.
+ Resititución de $s$ a un valor inicial luego de que alcance el valor umbral.

Las cuatro propiedades pueden conseguirse con un láser basado en el modelo Yamada de Q-switching pasivo #cite(<Yamada1993>). Éste describe un láser formado por una región activa (región a) y una región con absorción saturable (región s). La figura #ref(<fig:lasernahmias>) muestra un esquemático de una implementación en un VCSEL #cite(<Nahmias2013>).

#figure(
  square(fill: red),
  caption: [Esquemático de un VCSEL basado en el modelo Yamada que implementa el modelo de neurona LIF.]
) <fig:lasernahmias>


El sistema está descrito por un sistema de 3 ecuaciones diferenciales cuyas variables son la concentración del número de fotones $N_(p h)$ y las densidades de electrones en el medio activo y en el absorbente saturable ($n_a$ y $n_s$ respectivamente): 
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

#todo-inline([agregar $beta, B_r$, sacar $C$, Y PONER $theta(U)$])

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
    dot(I)(u) &=gamma_I [G(u) - Q(u) -1] I(u) + epsilon.alt f(G),
    dot(G)(u)&=gamma_G [A-G(u) - G(u)I(u)] + theta(u),
    dot(Q)(u)&=gamma_Q [B-Q(u) - a Q(u)I(u)],
  )
$ <eq:nahmias_bonitas>

donde:
#nonumeq(
$
  G &prop "Ganancia de la región "a"." \
  Q &prop "Absorción de la región "s"." \
  I &prop "Potencia de salida del láser."\
  gamma_G & = tau_(p h)/tau_a\
  gamma_Q & = tau_(p h)/tau_s\
  gamma_I &= 1\
  A &= A(I_A)\
  B &= B(I_S)\
  epsilon.alt f(u) &approx 0
$
)
#todo-inline([Poner definicion de $a$])

== Cumplimiento de condiciones de excitabilidad

=== Integración con pérdidas de la entrada al sistema en $G(u)$

En estado estacionario #footnote[El sistema se encuentra en estado estacionario si $theta(u) approx 0$ desde hace un tiempo #box[$T >> tau_(a), tau_(s), tau_(p h)$] ] el sistema se encuentra en un equilibrio estable. Por diseño, $G_(e q) -Q_(e q) -1<0$ y además $epsilon.alt f(G) approx 0$ por lo que $I(u) " es una exponencial decreciente que tiende a" 0$. 

$ 
  => cases(
    I(u) &= I_(e q) &approx 0,
    G(u) &= G_(e q) &= A,
    Q(u) &= Q_(e q) &= B,
  )
$

Como $I(u) approx 0$ y teniendo en cuenta la forma original de la ecuación #ref(<eq:nahmias_bonitas>), $G(u)$ y $Q(u)$ se encuentran desacopladas. Además, $tau_(a) >> tau_(s), tau_(p h)$ por lo que la respuesta de $G(u)$ ante perturbaciones es ordenes de magnitud más lenta que la de $Q(u)$ y $I(u)$. Por estos motivos, se puede considerar que $Q(u)$ y $I(u)$ se mantienen aproximadamente constantes incluso si la región $a$ recibe perturbaciones #box[$theta(u) != 0$], y que $G(u)$ funciona como un integrador de $theta(u)$ con pérdidas:

$ 
  => cases(
    I(u) &= I_(e q) approx 0,
    dot(G)(u) &= gamma_G [A - G(u) - G(u)I(u)] + theta(u),
    Q(u) &= Q_(e q) = B,
  )
$<eq:din_subthreshold>

Si se considera a G como el estado de la neurona, se cumple la condición de excitabilidad 1 (integración con pérdidas de la entrada al sistema).

Esta dinámica se mantiene siempre y cuando se cumpla que #box[$G(u) - Q(u) - 1 > 0$] $<=> G(u) < Q(u) + 1$ ya que $dot(I) approx gamma_I [G(u) -Q(u)-1]$. Se define
$
  G_(t h) = Q_(e q) + 1 = B +1
$

En caso de que $theta(u)$ sea una señal pulsada, $G(u)$ toma la forma que se ilustra en la figura #ref(<fig:GQI_pulso>) entre 0 y 120 unidades de tiempo.



=== Generación de un pulso en $I(u)$ cuando $G(u) >= G_(t h)(u)$

En caso de que $theta(u)$ la suficiente cantidad de pulsos lo suficientemente cerca, ocurre que $G(u)>= G_(t h)$ por lo que $I(u)$ crece exponencialmente. Esto resulta en una caída de $G(u)$ y $Q(u)$ (pérdida de ganancia y saturación de absorción). El pulso llega a su potencia máxima cuando $Q(u) approx 0$. Debido al decaimiento de $G(u)$ y $Q(u)$, eventualmente se deja de cumplir que el exponente de $I(u),$ #box[$G(u) -Q(u) -1$] deja de ser positivo y nuevamente es negativo, por lo que $I(u)$ decae con una constante de tiempo $approx 1/gamma_I$. De esta forma, se genera un pulso. (ver figura #ref(<fig:GQI_pulso>) entre 120 y 140 unidades de tiempo).

Por lo tanto, se cumplen las condiciones de excitabilidad 2 y 3 (comparación del estado de la neurona con un valor umbral y  generación de un pulso en respuesta).

=== Restitución de $G(u)$ a un valor inicial luego del pulso de $I(u)$

Luego de generar un pulso, $I(u) -> 0$. Por lo tanto, nuevamente $G(u)$ y $Q(u)$ pueden considerarse como variables con dinámicas desacopladas. El sistema se comporta como:

$
  &cases(
    I(u) approx 0,
    dot(G)(u)&=gamma_G [A-G(u)] + theta(u),
    dot(Q)(u)&=gamma_Q [B-Q(u)],
  )\
  => 
  &cases(
    G(u)->G_(e q) = A,
    Q(u)->Q_(e q) = B,
  )
$

Notar que como $gamma_G << gamma_I, gamma_Q$, $G(u)$ tarda más tiempo en reestablecerse a su valor de equilibrio que $Q(u)$. Esto dificulta que ocurra un segundo pulso porque temporalmente se cumpla que $G(u) > G_(t h) = Q(u)+1$ antes de que el sistema vuelva al equilibrio.#footnote([En el estudio de redes neuronales, el periodo inmediatamente posterior a un disparo en el cual es improbable (pero no imposible) que ocurra otro disparo es conocido como _periodo refractario relativo_. También existe el concepto de _periodo refractario absoluto_, en el cual es imposible que se genere un disparo, pero no está contemplado en la implementación del modelo neuronal LIF de #cite(<Nahmias2013>).])


#figure(
  image("images/pulso_QIG_nahmias.PNG"),
  caption: [Generación de disparo (obtenido de #ref(<Nahmias2013>)).]
)<fig:GQI_pulso>

== Comparación de modelo neuronal LIF teórico e implementación en VCSEL

Teniendo en mente que el objetivo es implementar un modelo neuronal:

- Las variables que se relacionan directamente con el comportamiento funcional de la neurona son $G(u)$ y $I(u)$.
- La codificación de información de la señal $I(u)$ está dada por la posición temporal de los pulsos generados, no por su forma o amplitud.
- La señal de entrada $theta(u)$ está formada unicamente por pulsos.

Bajo estas consideraciones, el sistema de ecuación #ref(<eq:nahmias_bonitas>) es funcionalmente equivalente a #ref(<eq:LIF_VCSEL>):

$
  cases(
    dot(G)(u) &= gamma_G [A-G(u)] + theta(u),
    I(u) &= sum_i^oo delta(u-u_f_i),
    G(u_f_i) &<-- A ,
  )\
  "Siendo " u_f_i = u slash.big G(u) >= B+1
$ <eq:LIF_VCSEL>


#todo-inline([
  - Cambio de variable a sistema G, I, Q, 
    - referenciar al anexo donde esta hecho el cambio de variable en mas detalle si es que tengo tiempo
  - decir algo sobre si $theta (u)$ es optico vs electrico
])

== Interconexión de neuronas VCSEL

Las ventajas de utilizar un VCSEL incluyen:
 + Pueden fabricarse de forma integrada ocupando poca área.
 + Pueden fabricarse en gran cantidad de forma interconectada.
Estas características favorecen su escalabilidad, potencialmente permitiendo generar redes con grandes cantidades de neuronas interconectadas. #todo([Esto queda medio colgado, quizas es mejor ponerlo al final o en otro lado.])


#todo-inline([ Mostrar al menos uno de los resultados avanzados del paper, tipo el de reconocimiento de patrones])

#show: appendix

= Equivalencia entre descripciones matemáticas

#todo-inline("TERMINAR EL ANEXO O BORRAR")


#bibliography("refs.bib")