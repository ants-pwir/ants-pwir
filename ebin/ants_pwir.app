{ application, ants_pwir,
  [ { description, "Simulation of an Ant Colony During And After Rain" },
    { vsn, "2.0" },
    { modules, [ controls, creation_handler, form, moves, sole_ant, sole_food, sole_pheromone, stream_of_creation, super_ant, super_food,
      super_main, super_pheromone, super_super, sole_raindrop, super_raindrop] },
    { registered, [] },
    { applications, [ kernel, stdlib] },
    { env, [] },
    { mod, { form, [] } }
  ]
}.