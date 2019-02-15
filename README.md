Ant simulation intended as a final project for the PWiR (Concurrent and Distributed Programming)
classes. 

To run, first write rebar3 shell to start rebar3. Then, initialize the app by writing observer:start(),application:start(ants_pwir), ants_app:start(gui). To start the application, press any button after a suitable message appears. Writing controls:start_rain(). , while the application is running, starts rain. controls:stop_rain(). stops rain. controls:get_data(). shows us data about the simulated world. Polecenie controls:stop_ants(). stops the simulation. You can exit by writing q or ok, and then pressing Enter. You can configure simulation data in parametres.hrl.
