#import "@preview/elsearticle:1.0.0": *
#import  "@preview/dashy-todo:0.1.2": todo


#let todo-inline = todo.with(position: "inline", stroke: (paint: red, thickness: 4pt, cap: "round"))

#set page(
  margin:(left: 1cm, right: 1cm)
)

#set math.cases(gap: 0.8em)
#show math.equation.where(block: true): set align(left)


// #show terms: it => {
//   it.children
//     .map(child => [
//       #grid(
//         columns: (2fr, 5fr),
//         align: (right, left),
//         column-gutter: 1em,
//         [#strong[#child.term: ]], [#child.description]
//       )
//       ])
//     .join()
// }
#show: elsearticle.with(
  title: [Implementación de modelo de neurona \
  _Leaky Integrate-and-Fire_ mediante VCSEL],
  authors: (
    (
      name: "María Luz Stewart Harris",
      affiliation: "Instituto Balseiro",
      // corr: "maria.stewart@ib.edu.ar",
    ),
  ),
  numcol: 2,
  // journal: "Name of the Journal",
  // abstract: abstract,
  // keywords: ("keyword 1", "keyword 2"),
  format:"3p",
  // line-numbering: true,
)



= Introducción

Las redes neuronales artificiales son con un modelo computacional muy utilizado en el área de inteligencia artificial cuya estructura tiene paralelismos con las redes neuronales biológicas. Está formadas por pequeñas unidades de computo llamadas neuronas artificiales que, en mayor o menor medida, tienen un funcionamiento similar a una neurona biológica. Tienen una gran variedades de aplicaciones, como por ejemplo reconocimiento de voz, generación y procesamiento de imágenes y traducción entre idiomas.

El tamaño de las redes neuronales artificales ha ido creciendo rápidamente en los últimos años, 
#footnote([Tomar como ejemplo las redes neuronales artificales GPT de OpenAI: en 2019 publicaron GPT-2, un modelo con 1500 millones de parámetros, y tan solo 4 años después lanzaron GPT-4, un modelo que se estima que tiene 1.76 billones de parámetros (la cantidad de parámetros es aproximadamente equivalente a la cantidad de conexiones neuronales).])
y en consecuencia su funcionamiento es cada vez mas computacionalmente costoso. Esta es una de las grandes motivaciones del área de investigación de _hardware neuromorfico_: procesadores de arquitecturas que se asemejen al de las redes neuronales de forma tal de poder ejecutarlas más rápidamente y/o más eficiente energéticamente. Mientras que estos sistemas suelen ser electrónicos (ver por ejemplo #cite(<ODIN>)), una rama del desarrollo del hardware neuromorfico investiga implementaciones fotónicas. Se describe a continuación un desarrollo de un VCSEL que implementa un modelo de neurona artificial.


= Modelos neuronales

Las neuronas (figura #ref(<fig:neurona>)), son células del sistema nervioso que intercambian información a través de señales eléctricas.
#figure(
  image("images/neurona.svg", width: 70%),
  caption: [Diagrama de una neurona. (#cite(<Neuron>))]
)<fig:neurona>

La figura #ref(<fig:Example_Vm>) muestra una medición del potencial eléctrico de la membrana de una neurona. 
Tal como se observa en la medición, la señal tiene pulsos de amplitud relativa grande.
Estos son llamados _disparos_ de la neurona. 
Los disparos son cruciales en la transmisión de información entre diferentes neuronas: la codificación de la información está dada en gran parte por la ubicación temporal de los disparos, y en menor medida por las otras características de la señal como la forma precisa del disparo o la forma de la señal en la ausencia de un disparo.

#figure(
  image("images/Example_Vm.PNG"),
  placement: auto,
  caption: [Ejemplo de medición de potencial de membrana de una neurona. Se observa que la señal tiene picos pronunciados, llamados disparos.]
)<fig:Example_Vm>

Es de sumo interés para la neurociencia comprender la relación entre las señales eléctricas de entrada y las de salida de una neurona para poder crear modelos que imiten su comportamiento. Existen modelos como el de Hodgkin--Huxley #cite(<HH>) que nacieron fruto del estudio de  mecanismos biológicos de la neurona, en donde no solo se intenta imitar la relación entre señales de entrada y de salida de una neurona, sino que esto se logra simulando variables internas biológicas de la célula.#footnote([Por ejemplo, se modela la permeabilidad de la membrana a diferentes iones y las corrientes iónicas resultantes.]) También existen modelos "a caja negra" en donde solamente se intenta replicar la funcionalidad de una neurona pero no el mecanismo biológico interno. Muchos de estos modelos neuronales por simplicidad asumen que las señales interneuronales son únicamente sumatoria de disparos a lo largo del tiempo, e incluso consideran al disparo como una delta de Dirac ya que se considera a su duración $->0$.


== Modelo de neurona _Leaky Integrate-and-Fire_

Los modelos neuronales en donde se considera a las entradas y salidas como una sumatoria de pulsos distribuidos en el tiempo son la base de las redes neuronales artificiales de impulsos, o _Spiking Neuronal Networks_ (SSN) #cite(<Maass1997>). En estas redes, el único intercambio que ocurre entre neuronas es el de pulsos de igual amplitud en diferentes momentos. Se puede interpretar como que las señales entre neuronas son analógicas en el tiempo y digitales en amplitud.

Un ejemplo de este modelo es el  _Leaky Integrate-and-Fire_ (LIF) #cite(<Abbott1999>), descrito por el sistema de ecuaciones #ref(<eq:LIF>). La variable $s(t),$ comunmente denominada el _estado de la neurona_, funciona como un integrador con pérdidas de $x(t)$ (la entrada a la neurona). $s(t)$ es continuamente comparada con un valor umbral $s_(t h)$. Cuando $s(t) > s_(t h)$, se genera un pulso en la salida $y(t)$ y $s(t)$ se reestablece a un valor de reposo $s_("rest")$.


$
  cases(
    dot(s)(t) = 1/tau_s [s_("rest")-s(t)] + x(t),
    y(t) = sum_i^oo delta(t-t_f_i),
    s(t_f_i + dif t) = s_("reset") ,
  )
$ <eq:LIF>
Siendo $t_f_i = t slash.big s(t) >= s_(t h),$ es decir, los tiempos en los que $s(t)$ supera el valor umbral $s_(t h)$ (también llamados _tiempos de disparos_).

#figure(
  image("images/LIF.PNG", width: 50%),
  placement: auto,
  caption: [Modelo de neurona _Leaky Integrate-and-Fire_ (LIF). #cite(<LIF>)\
  Curva roja: el estado de la neurona $s(t)$\
  Flechas rojas: pulsos de entrada a la neurona $x(t)$\
  Fecha verde: pulso de salida de la neurona y(t)\
  #v(10pt)
  ]
)<fig:LIF>



= Implementación del modelo de neurona LIF en láser VCSEL

Un sistema que implemente un modelo de neurona LIF debe cumplir las siguientes condiciones, llamadas _condiciones de excitabilidad_:

+ Una variable $s,$ considerada el estado de la neurona, que funcione como integrador con pérdidas de la entrada al sistema.
+ Comparación de $s$ con un valor umbral.
+ Generación de un pulso cuando $s$ alcance el valor umbral.
+ Resititución de $s$ a un valor inicial luego de que alcance el valor umbral.

Las cuatro propiedades pueden conseguirse con un láser basado en el modelo Yamada de Q-switching pasivo #cite(<Yamada1993>). Éste describe un láser formado por una región activa (región a) y una región con absorción saturable (región s). La figura #ref(<fig:lasernahmias>) muestra un esquemático de una implementación en un VCSEL #cite(<Nahmias2013>).

#figure(
  image("images/VCSEL.PNG", width: 50%),
  placement: auto,
  caption: [Esquemático de un VCSEL basado en el modelo Yamada que implementa el modelo de neurona LIF.]
) <fig:lasernahmias>


El sistema está descrito por un sistema de 3 ecuaciones diferenciales cuyas variables son la concentración del número de fotones $N_(p h)$ y las densidades de electrones en el medio activo y en el absorbente saturable ($n_a$ y $n_s$ respectivamente) (ecuación #ref(<eq:nahmias_feas>)), donde: 

// #place(
//   top,
//   scope: "parent",
//   float: true,
// [
  $
  cases(
    (dif N_(p h))/(dif t) = [ Gamma_a tilde(G)_a + Gamma_2 tilde(G)_s - 1/tau_(p h)]N_(p h) +  V_1 beta B_r n_a^2,

    (dif n_a)/(dif t) = -(Gamma_1)/V_a tilde(G)_a (N_(p h)-phi.alt(t)) - n_a/tau_a + (I_a+i_e (t))/(e V_a),

    (dif n_s)/(dif t) = -(Gamma_s)/V_s tilde(G)_s N_(p h) - n_s/tau_s + I_s/(e V_s),
  )
$<eq:nahmias_feas>
#nonumeq($
    tilde(G)_a = g_a (n_a - n_(a 0)) approx G_a\ 
    tilde(G)_s = g_s (n_s - n_(s 0)) approx G_s
$)
#v(10pt)
// ]
// )
/ $g_(a,s)$: Constante de proporcionalidad entre el coeficiente de ganancia y la densidad de electrones en la región $(a,s)$.
/ $Gamma_(a,s)$: Coeficiente de confinamiento de la región $(a,s)$.
/ $n_((a,s) 0)$: Densidad de electrones umbral a partir de la cual la ganancia de la region (a,s) es positiva.
/ $tau_(p h)$: Vida media de un fotón.
/ $tau_(a, s)$: Vida media del estado superior en la región $(a,s)$.
/ $V_(a, s)$: Volumen de la región (a,s).
/ $G_(a,s)$: Ganancia de la región (a,s). Se aproxima con una serie de Taylor de primer orden tal que  $G_(a,s) approx g_(a,s) (n_(a,s) - n_((a,s)0))$.
/ $beta$: factor de acoplamiento de emisión espontánea.
/ $B_r$: término de recombinación bimolecular.
/ $I_(a,s)$: corriente de bombeo constante en la región $(a,s)$.
/ $i_e (t)$: corriente de bombeo variable en la región $a$.


Aplicando el cambio de variable de las ecuaciones #ref(<eq:cambio_variable_nahmias>) se obtiene la descripción equivalente del sistema de las ecuaciones #ref(<eq:nahmias_bonitas>).

$
  cases(
    u &= t/tau_(p h),
    G(u)&=tau_(p h) Gamma_a g_a (n_a (t)-n_(a 0)),
    Q(u)&=tau_(p h) Gamma_s g_s (n_(s 0)-n_s (t)),
    I(u) &= (tau_a Gamma_a g_a) /V_a N_(p h)(t)
  )
$ <eq:cambio_variable_nahmias>

$
  cases(
    dot(I)(u)=gamma_I [G(u) - Q(u) -1] I(u) + epsilon.alt f(G),
    dot(G)(u)=gamma_G [A-G(u) - G(u)I(u)] + theta(u)"         ",
    dot(Q)(u)=gamma_Q [B-Q(u) - a Q(u)I(u)],
  )
$ <eq:nahmias_bonitas>

#nonumeq(
$
  G prop "Ganancia de la región "a"." \
  Q prop "Absorción de la región "s"." \
  I prop "Potencia de salida del láser."\
  theta prop "Modulación de ganancia de la región "a"."\
  gamma_G  = tau_(p h)/tau_a\
  gamma_Q  = tau_(p h)/tau_s\
  gamma_I = 1\
  a = (tau_s Gamma_s g_s V_a)/ (tau_a Gamma_a g_a V_s)\
  A= A(I_A)\
  B= B(I_s)\
  epsilon.alt f(u) approx 0\
$
)

== Cumplimiento de condiciones de excitabilidad

=== Integración con pérdidas de la entrada al sistema en $G(u)$

En estado estacionario #footnote[El sistema se encuentra en estado estacionario si $theta(u) approx 0$ desde hace un tiempo #box[$T >> tau_(a), tau_(s), tau_(p h)$] ] el sistema se encuentra en un equilibrio estable. Por diseño, $G_(e q) -Q_(e q) -1<0$ y además $epsilon.alt f(G) approx 0$ por lo que $I(u)$ es una exponencial decreciente que tiende a $0$. 

#nonumeq(
$ 
  cases(
    I(u) &= I_(e q) &approx 0,
    G(u) &= G_(e q) &= A,
    Q(u) &= Q_(e q) &= B,
  )
$
)

Como $I(u) approx 0$ y teniendo en cuenta la forma original de la ecuación #ref(<eq:nahmias_bonitas>), $G(u)$ y $Q(u)$ se encuentran desacopladas. Además, $tau_(a) >> tau_(s), tau_(p h)$ por lo que la respuesta de $G(u)$ ante perturbaciones es ordenes de magnitud más lenta que la de $Q(u)$ y $I(u)$. Por estos motivos, se puede considerar que $Q(u)$ y $I(u)$ se mantienen aproximadamente constantes incluso si la región $a$ recibe perturbaciones #box[$theta(u) != 0$], y que $G(u)$ funciona como un integrador de $theta(u)$ con pérdidas:

#nonumeq(
$ 
  cases(
    I(u) &= I_(e q) approx 0,
    dot(G)(u) &= gamma_G [A - G(u) - G(u)I(u)] + theta(u),
    Q(u) &= Q_(e q) = B,
  )
$
)
Si se considera a G como el estado de la neurona, se cumple la condición de excitabilidad 1 (integración con pérdidas de la entrada al sistema).

Esta dinámica se mantiene siempre y cuando se cumpla que #box[$G(u) - Q(u) - 1 > 0$] $<=>$ #box[$G(u) < Q(u) + 1$] ya que #box[$dot(I) approx gamma_I [G(u) -Q(u)-1]$]. Se define:
#nonumeq(
$
  G_(t h) = Q_(e q) + 1 = B +1
$
)
En caso de que $theta(u)$ sea una señal pulsada, $G(u)$ toma la forma que se ilustra en la figura #ref(<fig:GQI_pulso>) entre 0 y 120 unidades de tiempo.



=== Generación de un pulso en $I(u)$ cuando $G(u) >= G_(t h)(u)$

En caso de que $theta(u)$ la suficiente cantidad de pulsos lo suficientemente cerca, ocurre que $G(u)>= G_(t h)$ por lo que $I(u)$ crece exponencialmente. Esto resulta en una caída de $G(u)$ y $Q(u)$ (pérdida de ganancia y saturación de absorción). El pulso llega a su potencia máxima cuando $Q(u) approx 0$. Debido al decaimiento de $G(u)$ y $Q(u)$, eventualmente se deja de cumplir que el exponente de $I(u),$ #box[$G(u) -Q(u) -1$] deja de ser positivo y nuevamente es negativo, por lo que $I(u)$ decae con una constante de tiempo $approx 1/gamma_I$. De esta forma, se genera un pulso. (ver figura #ref(<fig:GQI_pulso>) entre 120 y 140 unidades de tiempo).

Por lo tanto, se cumplen las condiciones de excitabilidad 2 y 3 (comparación del estado de la neurona con un valor umbral y  generación de un pulso en respuesta).

=== Restitución de $G(u)$ a un valor inicial luego del pulso de $I(u)$

Luego de generar un pulso, #box($I(u) -> 0$). Por lo tanto, nuevamente $G(u)$ y $Q(u)$ pueden considerarse como variables con dinámicas desacopladas. El sistema se comporta como:

#nonumeq(
$
  &cases(
    I(u) approx 0,
    dot(G)(u)=gamma_G [A-G(u)] + theta(u),
    dot(Q)(u)=gamma_Q [B-Q(u)],
  )\
  &cases(
    G(u)->G_(e q) = A,
    Q(u)->Q_(e q) = B,
  )
$
)

Notar que como $gamma_G << gamma_I, gamma_Q$, $G(u)$ tarda más tiempo en reestablecerse a su valor de equilibrio que $Q(u)$. Esto dificulta que ocurra un segundo pulso porque temporalmente se cumpla que $G(u) > G_(t h) = Q(u)+1$ antes de que el sistema vuelva al equilibrio.#footnote([En el estudio de redes neuronales, el periodo inmediatamente posterior a un disparo en el cual es improbable (pero no imposible) que ocurra otro disparo es conocido como _periodo refractario relativo_. También existe el concepto de _periodo refractario absoluto_, en el cual es imposible que se genere un disparo, pero no está contemplado en la implementación del modelo neuronal LIF de #cite(<Nahmias2013>).])


#figure(
  image("images/pulso_QIG_nahmias.PNG"),
  placement: auto,
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
    dot(G)(u) = gamma_G [A-G(u)] + theta(u),
    I(u) = sum_i^oo delta(u-u_f_i),
    G(u_f_i + dif u) = A ,
  )\
$ <eq:LIF_VCSEL>

Siendo $u_f_i = u slash.big G(u) >= B+1$

El sistema de ecuaciones #ref(<eq:LIF_VCSEL>) es algebraicamente equivalente al del modelo de neurona LIF #ref(<eq:LIF>). Entonces, el VCSEL descrito implementa un modelo neuronal LIF con las siguientes correspondencias:

#figure(
  table(
    columns: (auto, auto),
    inset: 10pt,
    align: center + horizon,
    table.header(
      [*Modelo LIF*], [*VCSEL*],
    ),
    $x(t)$,$theta(u)$,
    $s(t)$,$G(u)$,
    $y(t)$,$I(u)$
  ),
  placement: auto,
  caption: [Correspondencia entre parámetros del modelo LIF y el VCSEL.]
)<tab:LIF_VCSEL_correspondencia>

== Interconexión de neuronas VCSEL

Las ventajas de utilizar un VCSEL incluyen:
 + Pueden fabricarse de forma integrada ocupando poca área.
 + Pueden fabricarse en gran cantidad de forma interconectada.
Estas características favorecen su escalabilidad, potencialmente permitiendo generar redes con grandes cantidades de neuronas interconectadas.

#colbreak()

#bibliography("refs.bib")