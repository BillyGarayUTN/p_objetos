// Sistema Counter-Strike

///////////////  ENFRENTAMIENTO ///////////////

class Enfrentamiento {
    const property equipoTerroristas
    const property equipoCounterTerroristas  
    var property partidas = []
    
    method jugarPartida() {
        const nuevaPartida = new Partida(
            equipoA = equipoTerroristas,
            equipoB = equipoCounterTerroristas,
            numeroPartida = partidas.size() + 1
        )
        
        // Crear avatares para cada jugador basado en su historial
        nuevaPartida.crearAvataresParaJugadores()
        
        partidas.add(nuevaPartida)
        return nuevaPartida
    }
    
    method estaTerminado() = 
        self.equipoGanador() != null
    
    method equipoGanador() {
        const victoriasT = self.victoriasEquipo(equipoTerroristas)
        const victoriasCT = self.victoriasEquipo(equipoCounterTerroristas)
        
        if (victoriasT >= 16 && (victoriasT - victoriasCT) >= 2) {
            return equipoTerroristas
        }
        if (victoriasCT >= 16 && (victoriasCT - victoriasT) >= 2) {
            return equipoCounterTerroristas
        }
        return null
    }
    
    method victoriasEquipo(equipo) = 
        partidas.count { partida => partida.equipoGanador() == equipo }
    
    // PUNTO 2: MVP del enfrentamiento
    method mvp() = 
        self.todosLosJugadores().max { jugador => jugador.eficiencia() }
    
    method todosLosJugadores() = 
        equipoTerroristas.jugadores() + equipoCounterTerroristas.jugadores()
    
    // PUNTO 4: Crear siguiente partida
    method crearSiguientePartida() = self.jugarPartida()
}

///////////////  PARTIDA ///////////////

class Partida {
    const property equipoA
    const property equipoB
    const property numeroPartida
    var property equipoGanador = null
    var property avataresPartida = []
    
    method crearAvataresParaJugadores() {
        equipoA.jugadores().forEach { jugador => 
            const avatar = jugador.crearAvatar(numeroPartida)
            avataresPartida.add(avatar)
        }
        equipoB.jugadores().forEach { jugador => 
            const avatar = jugador.crearAvatar(numeroPartida)
            avataresPartida.add(avatar)
        }
    }
    
    method terminarPartida(equipoVencedor) {
        equipoGanador = equipoVencedor
        // Calcular premios para todos los avatares
        avataresPartida.forEach { avatar => avatar.calcularPremio() }
    }
    
    method avatarDeJugador(jugador) = 
        avataresPartida.find { avatar => avatar.jugador() == jugador }
    
    // PUNTO 5: Afectar partida con compras
    method procesarCompras(compras) {
        compras.forEach { compra => 
            const jugador = compra.jugador()
            const avatar = self.avatarDeJugador(jugador)
            avatar.comprarEquipamiento(compra.items())
        }
    }
}

///////////////  EQUIPO ///////////////

class Equipo {
    const property nombre  // "Terroristas" o "Counter-Terroristas"  
    const property tipo    // "TT" o "CT"
    var property jugadores = []
    
    method agregarJugador(jugador) {
        jugadores.add(jugador)
        jugador.equipo(self)
    }
    
    method armaReglamentaria() = 
        if (tipo == "TT") new AK47() else new M4A4()
}

///////////////  JUGADOR ///////////////

class Jugador {
    const property nickname
    var property equipo
    var property historialCompras = []
    var property avatares = []  // Un avatar por partida jugada
    
    method crearAvatar(numeroPartida) {
        const esLaPrimeraPartida = numeroPartida == 1
        const dineroInicial = if (esLaPrimeraPartida) 800 else self.calcularDineroParaNuevaPartida()
        const armas = if (esLaPrimeraPartida) [equipo.armaReglamentaria()] else self.armasParaNuevaPartida()
        
        const nuevoAvatar = new Avatar(
            jugador = self,
            numeroPartida = numeroPartida,
            dinero = dineroInicial,
            armas = armas
        )
        
        avatares.add(nuevoAvatar)
        return nuevoAvatar
    }
    
    method calcularDineroParaNuevaPartida() {
        const avatarAnterior = self.ultimoAvatar()
        const dineroAnterior = avatarAnterior.dinero()
        const premioAnterior = avatarAnterior.premio()
        return dineroAnterior + premioAnterior
    }
    
    method armasParaNuevaPartida() {
        const avatarAnterior = self.ultimoAvatar()
        return if (avatarAnterior.sobrevivio()) 
            avatarAnterior.armas() 
        else 
            [equipo.armaReglamentaria()]
    }
    
    method ultimoAvatar() = avatares.last()
    
    method registrarCompra(compra) {
        historialCompras.add(compra)
    }
    
    // PUNTO 1: Números finales del jugador
    method killsTotales() = 
        avatares.sum { avatar => avatar.eliminaciones().size() }
    
    method cantidadVecesMatado() = 
        avatares.count { avatar => !avatar.sobrevivio() }
    
    method eficiencia() = 
        (self.killsTotales() - self.cantidadVecesMatado()).max(0)
    
    // PUNTO 6: Plata gastada total
    method plataGastada() = 
        historialCompras.sum { compra => compra.precio() }
}

///////////////  AVATAR ///////////////

class Avatar {
    const property jugador
    const property numeroPartida
    var property dinero
    var property armas = []
    var property sobrevivio = true
    var property eliminaciones = []
    var property premio = 0
    
    method comprarArma(arma) {
        if (dinero >= arma.precio()) {
            dinero -= arma.precio()
            armas.add(arma)
            const compra = new Compra(avatar = self, item = arma, precio = arma.precio())
            jugador.registrarCompra(compra)
        } else {
            self.error("No tienes suficiente dinero para comprar " + arma.nombre())
        }
    }
    
    method eliminarJugador(otroAvatar) {
        eliminaciones.add(otroAvatar)
        otroAvatar.morir()
    }
    
    method morir() {
        sobrevivio = false
    }
    
    method eficiencia() = 
        if (eliminaciones.isEmpty()) 0 else eliminaciones.size() / 2.0
    
    method calcularPremio() {
        const eficienciaPremio = self.eficiencia() * 800
        premio = eficienciaPremio.max(800).min(3500)
    }
    
    // PUNTO 3: Compra de equipamiento conjunto
    method comprarEquipamiento(items) {
        const costoTotal = items.sum { item => item.precio() }
        
        if (dinero >= costoTotal) {
            // Compra exitosa - compra todos los items
            items.forEach { item => 
                dinero -= item.precio()
                armas.add(item)
                const compra = new Compra(avatar = self, item = item, precio = item.precio())
                jugador.registrarCompra(compra)
            }
        } else {
            // No puede comprar todos - no compra ninguno
            self.error("No tienes suficiente dinero para comprar todo el equipamiento (necesitas $" + costoTotal + ", tienes $" + dinero + ")")
        }
    }
}

///////////////  ARMAS ///////////////

class Arma {
    method nombre()
    method precio()
    method danio()
    
    override method toString() = self.nombre()
}

class AK47 inherits Arma {
    override method nombre() = "AK-47"
    override method precio() = 0  // Arma reglamentaria
    override method danio() = 36
}

class M4A4 inherits Arma {
    override method nombre() = "M4A4"
    override method precio() = 0  // Arma reglamentaria  
    override method danio() = 33
}

class AWP inherits Arma {
    override method nombre() = "AWP"
    override method precio() = 4750
    override method danio() = 115
}

class Deagle inherits Arma {
    override method nombre() = "Desert Eagle"
    override method precio() = 700
    override method danio() = 53
}

///////////////  COMPRA ///////////////

class Compra {
    const property avatar
    const property item
    const property precio
    const property fecha = new Date()
    
    override method toString() = 
        avatar.jugador().nickname() + " compró " + item.nombre() + " por $" + precio
}

// Clase para agrupar compras de un jugador (PUNTO 5)
class CompraJugador {
    const property jugador
    const property items
    
    method costoTotal() = items.sum { item => item.precio() }
}

///////////////  EQUIPAMIENTO ADICIONAL ///////////////

class Chaleco inherits Arma {
    override method nombre() = "Chaleco antibalas"
    override method precio() = 650
    override method danio() = 0  // No es arma ofensiva
}

class Granada inherits Arma {
    override method nombre() = "Granada HE"
    override method precio() = 300
    override method danio() = 57
}

class Flashbang inherits Arma {
    override method nombre() = "Flashbang"
    override method precio() = 200
    override method danio() = 0  // No hace daño directo
}