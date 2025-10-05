#import "@preview/elsearticle:1.0.0": *
#import  "@preview/dashy-todo:0.1.2": todo


#let todo-inline = todo.with(position: "inline", stroke: (paint: red, thickness: 4pt, cap: "round"))

#set math.cases(gap: 0.8em)

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

Un sistema que implemente un modelo de neurona LIF debe tener las siguientes propiedades:#todo([Explicar que estas propiedad se pueden resumir en el concepto de "excitabilidad" y citar el paper que lo define])

+ Integración de una variable del sistema $s$, considerada el estado de la neurona.
+ Comparación de $s$ con un valor umbral.
+ Resititución de $s$ a un valor inicial luego de que alcance el valor umbral.
+ Generación de un pulso cuando $s$ alcance el valor umbral.


#todo-inline([
  - Citar a Yamada: #cite(<Yamada1993>)
  - Describio un sistema de laser pulsado Q-switch con region de ganancia y region absorción saturable
  - Ecuaciones Yamada
  - relacion entre tiempos tau1, tau2, y tauph, y algun que otro valor importante de los parametros del modelo])

#todo-inline([
  - Ecuaciones originales de #cite(<Nahmias2013>), explicar como se parecen y como se distinguen de las de Yamada
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
  (dif n_s)/(dif t) &= -Gamma_s g_s (n_s - n_(s 0))(N_(p h)/V_s)-n_s/tau_s + I_s/(e V_s),
  (dif N_(p h))/(dif t) &= (Gamma_a g_a (n_a - n_(a 0)) + Gamma_s g_s (n_s - n_(s 0)) -1/tau_(p h)) N_(p h) + V_a beta B_r n_a^2
  ) 
$ <eq:anexo_a_nahmias_original>

Se aplica un cambio de variables a la ecuación #ref(<eq:anexo_a_nahmias_original>):

$
  cases(
    u &= t/tau_(p h),
    G(u)&=tau_(p h) Gamma_a g_a (n_a (t)-n_(a 0)) &= tau_(p h) Gamma_a g_a (n_a (u tau_(p h))-n_(a 0)),
    Q(u)&=tau_(p h) Gamma_s g_s (n_(s 0)-n_s (t)) &= tau_(p h) Gamma_s g_s (n_(s 0)-n_s (u tau_(p h))),
    I(u) &= (tau_a Gamma_a g_a) /V_a N_(p h)(t) &= (tau_a Gamma_a g_a) /V_a N_(p h)(u tau_(p h))
  )
$ <eq:anexo_a_cambio_variable>

Reemplazando #ref(<eq:anexo_a_cambio_variable>) en #ref(<eq:anexo_a_nahmias_original>):


#bibliography("refs.bib")