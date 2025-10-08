#import "@preview/touying:0.5.5": *
#import "@preview/clean-math-presentation:0.1.1": *

#show: clean-math-presentation-theme.with(
  config-info(
    title: [Implementación de modelo de neurona \ _Leaky Integrate-and-Fire_ mediante VCSEL],
    short-title: [Modelos neuronales con VCSEL],
    authors: (
      (name: "María Luz Stewart Harris")),
    author: "María Luz Stewart Harris",
    date: datetime(year: 2025, month: 10, day: 8),
  ),
  config-common(
    slide-level: 2,
    //handout: true,
    //show-notes-on-second-screen: right,
  ),
  progress-bar: true,
  align: horizon
)

#title-slide(
  logo1: image("images/Instituto-Balseiro.png", height: 4.5em),
)


= Introducción

#slide(title: "Temas")[
  - Motivación
  - Modelo neuronal _Leaky Integrate-and-Fire_
  - Implementación de modelo neuronal LIF con un VCSEL
]

= Motivación

#focus-slide[
  ¿Por qué nos interesa modelar neuronas con láseres?
]

#slide(title:"Potencial del hardware neuromórfico")[
    #definition(title: "Hardware neuromorfico", blocktitle: "Definición")[
    Procesadores con arquitecturas que se asemejen al de las redes neuronales.
  ]
  #pause
  - Mejoras de costo energético/latencia en redes neuronales artificiales grandes comparado con arquitecturas tradicionales (CPU / GPU).
  #pause
  - Arreglos de VCSEL: integración densa y fabricación a escala ⇒ red de neuronas en chip
]

= Modelo LIF

#focus-slide[
  ¿Qué es el modelo neuronal LIF?
]


#slide(title: "Spiking Neural Networks")[
  #definition(title: "Spiking Neural Networks / SNN", blocktitle: "Definición")[
    Redes neuronales artificiales en el que el único intercambio que ocurre entre neuronas es el de pulsos de igual amplitud en diferentes instantes.
  ]
  #pause
  - La comunicación entre neuronas biológicas sucede a través de señales eléctricas que contienen pulsos \
  #align(center, image("images/Example_Vm.PNG", width: 50%))
  #pause
  - En una SNN, la información se codifica exclusivamente por la posición de los pulsos transmitidos, no por la amplitud ni la forma de los pulsos.
  #pause
  - Existen muchos modelos matemáticos que aproximan la relación entre pulsos de entrada y pulsos de salida de una neurona, entre ellos el modelo _Leaky Integrate-and-Fire_ (LIF).
]

#slide(title: "LIF")[
  #definition(title: "Modelo LIF", blocktitle:"Definición")[
  $
    cases(
      dot(s)(t) = 1/tau_s [s_("rest")-s(t)] + x(t),
      y(t) = sum_i^oo delta(t-t_f_i),
      s(t_(f_i) ^+) = s_("rest") ,
    )
  $ <eq:LIF>
  - $t_f_i$: $t$ tal que $s(t) >= s_(t h),$
  - $x(t)$: entrada (pulsos)
  - $s(t)$: estado de la neurona
  - $y(t)$: tren de deltas (disparos)
  ]
]

#slide(title: "LIF")[
  #grid(align: (center+horizon, center+horizon), columns: (1fr, 1fr),
    [
    $
      cases(
        dot(s)(t) = 1/tau_s [s_("rest")-s(t)] + x(t),
        y(t) = sum_i^oo delta(t-t_f_i),
        s(t_(f_i) ^+) = s_("rest") ,
      )
    $],
    [
    #image("images/LIF.PNG", height: 50%)@LIF
    ]
  )
]

= Implementación de modelo LIF en un VCSEL

#focus-slide[
  ¿Cómo implemento un modelo LIF en un VCSEL?
]

#slide(title: "Requerimientos de implementación de modelo LIF")[
  #grid(align: (center+horizon, left+horizon), columns: (1fr, 1fr),
    [
    #image("images/LIF.PNG", height: 50%)@LIF
    ],
    [
      Una implementación de modelo LIF debe poder:
      - Integrar con pérdidas la señal de entrada.
      - Comparar la integral con un valor umbral.
      - Generar un pulso cuando la integral supere el umbral.
      - Restablecer el valor de la integral luego de que supere el umbral.
    ]
    
  )
]

#slide(title: "Implementación de modelo LIF en un VCSEL")[

  Se puede implementar un modelo LIF en un VCSEL con absorbente saturable similar al modelo Yamada. (@Yamada1993 @Nahmias2013)
]

#slide(title: "Implementación de modelo LIF en un VCSEL")[
  #grid(align: (center+horizon, left+horizon), columns: (1fr, 1fr),
    [
    #image("images/VCSEL.PNG", height: 80%)@Nahmias2013
    ],
    [
    #pause
    - VCSEL con dos secciones:
      - Medio de ganancia activo con ganancia normalizada $G$ que modela al estado de la neurona.
      - Absorbente saturable con absorción normalizada $Q$.
    #pause
    - Modulación de la ganancia $theta$ modula la entrada a la neurona
    #pause
    - Intensidad de salida normalizada $I$ modela la salida de la neurona.
    ]
  ) 
]

#slide(title: "Implementación de modelo LIF en un VCSEL")[
$
  cases(
    dot(I) =gamma_I [G  - Q  -1] I  + epsilon.alt f(G),
    dot(G) =gamma_G [A-G  - G I ] + theta "         ",
    dot(Q) =gamma_Q [B-Q  - a Q I ],
  )
$ <eq:nahmias_bonitas>
$
  1/gamma_I << 1/gamma_Q << 1/gamma_G
$
]

#slide(title: "Implementación de modelo LIF en un VCSEL")[
== Régimen previo al umbral ($t<120$)
  #grid(columns:(1fr,1fr), align:(center, center),
    [
      #image("images/pulso_QIG_nahmias.PNG", height: 70%)@Nahmias2013
    ],
    [
      $
        cases(
          dot(I) &=gamma_I [G  - Q  -1] I,
          dot(G) &=gamma_G [A-G  - G I ] + theta "         ",
          dot(Q) &=gamma_Q [B-Q  - a Q I ],
        )\
        #pause
        arrow.b.double\
        cases(
          I  &= I_(e q) approx 0,
          dot(G)  &= gamma_G [A - G] + theta ,
          Q &= Q_(e q) = B,
        )
      $
    ]
  )
]

#slide(title: "Implementación de modelo LIF en un VCSEL")[
== Generación del disparo ($t approx 125$)
  #grid(columns:(1fr,1fr), align:(center, center),
  [
    #image("images/pulso_QIG_nahmias.PNG", height: 70%)@Nahmias2013
  ],
  [
    $
      cases(
        dot(I)&=gamma_I [G - Q -1] I,
        dot(G)&=gamma_G [A-G - G I] + theta"         ",
        dot(Q)&=gamma_Q [B-Q - a Q I],
      )\
      #pause
      arrow.b.double
    $
    Si $G - Q - 1 > 0$\
    $
      &=> I "crece exponencialmente"\
      &=> arrow.b Q " y " arrow.b G\
      &=> G - Q - 1 < 0\
      &=> I "decrece exponencialmente"
    $
  ])
]

#slide(title: "Implementación de modelo LIF en un VCSEL")[
== Luego del disparo ($t>130$)
  #grid(columns:(1fr,1fr), align:(center, center),
    [
      #image("images/pulso_QIG_nahmias.PNG", height: 70%) @Nahmias2013
    ],
    [
      $
        cases(
          dot(I) &=gamma_I [G  - Q  -1] I,
          dot(G) &=gamma_G [A-G  - G I ] + theta "         ",
          dot(Q) &=gamma_Q [B-Q  - a Q I ],
        )\
        #pause
        arrow.b.double\
        cases(
          I  &= I_(e q) approx 0,
          dot(G)  &= gamma_G [A - G] + theta ,
          Q &= Q_(e q) = B,
        )
      $\
    $("Recordar que " 1/gamma_I << 1/gamma_Q << 1/gamma_G)$
    ]
  )
]

#slide(title: "Implementación de modelo LIF en un VCSEL")[
== Repaso de condiciones necesarias para implementaciones de modelo LIF
  #grid(columns:(4fr,5fr), align:(left, center), column-gutter: 1em,
    [
      #image("images/pulso_QIG_nahmias.PNG", height: 70%)
    ],
    [
      #align(left)[
        $checkmark$ Integrar con pérdidas la señal de entrada. \
        $checkmark$ Comparar la integral con un valor umbral. \
        $checkmark$ Generar un pulso cuando la integral supere el umbral. \
        $checkmark$ Restablecer el valor de la integral luego de que supere el umbral. \
      ]
      #math.arrow.double El VCSEL con absobente saturable implementa el modelo neuronal LIF!
    ]
  )
]



#focus-slide[
  ¡Muchas gracias!
]

#show: appendix

= References

#slide(title: "References")[
  #bibliography("refs.bib", title: [Referencias])
]

= Appendix

#focus-slide("Apéndice")

#slide(title: "Ejemplo de redes mínimas")[
#figure(
  image("images/bistable.PNG"),
  caption: [Circuito biestable formado por dos neuronas interconectadas.]
  )
]

#slide(title: "Ejemplo de redes mínimas")[
#figure(
  grid(columns: (2fr, 3fr),
    [
    #image("images/repetidorpatron_neuronas.PNG")
    ],
    [
    #image("images/repetidorpatron_señales.PNG")
    ]
  ),
  caption: [Circuito de 4 neuronas con capacidad de repetir un patrón de pulsos de entrada. @Nahmias2013]
  )
]

#slide(title: "Ejemplo de redes mínimas")[
#figure(
  grid(columns: (2fr, 3fr),
    [
    #image("images/repetidorpatron_neuronas.PNG")
    ],
    [
    #image("images/repetidorpatron_señales.PNG")
    ]
  ),
  caption: [Circuito de 4 neuronas con capacidad de repetir un patrón de pulsos de entrada. @Nahmias2013]
  )
]

#slide(title: "Conexiones entre neuronas fotónicas")[
  #figure(
  image("images/conexionadoSNN.png"),
  caption: [Esquemático de conexiones en una SNN fotónica. @Nahmias2013]
  )
]