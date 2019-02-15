# Description

Ant simulation intended as a final project for the PWiR (Concurrent and Distributed Programming)
classes.

# Running

To run, first write rebar3 shell to start rebar3. Then, initialize the app by writing `observer:start(),application:start(ants_pwir).` To start the application, write `controls:start_ants().`. Writing `controls:start_rain().`, while the application is running, starts rain. `controls:stop_rain().` stops rain. `controls:get_data().` shows us data about the simulated world. Polecenie `controls:stop_ants().` stops the simulation. You can configure simulation data in parametres.hrl.
