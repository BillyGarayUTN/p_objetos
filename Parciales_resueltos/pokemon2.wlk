// Sistema Pokémon Simplificado

///////////////  POKÉMON ///////////////

class Pokemon {
    const property nombre
    const property vidaMaxima
    var property vidaActual
    var property movimientos = []
    var property condicion = new CondicionNormal()
    
    method initialize() {
        vidaActual = vidaMaxima  // Inicia con vida completa
    }
    
    // PUNTO 1: Grositud del pokémon
    method grositud() = vidaMaxima * self.sumaPoderMovimientos()
    
    method sumaPoderMovimientos() = movimientos.sum { movimiento => movimiento.poder() }
    
    method estaVivo() = vidaActual > 0
    
    method puedeMoverse() = self.estaVivo() && condicion.permiteMoverse()
    
    // PUNTO 2.2: Luchar con otro pokémon
    method luchar(oponente, movimiento) {
        if (!self.puedeMoverse()) {
            condicion.alNoPoderMoverse(self)
            return "No puede moverse"
        }
        
        if (!movimiento.puedeUsarse()) {
            return "El movimiento no tiene más usos"
        }
        
        // Usar el movimiento
        movimiento.usar(self, oponente)
        
        // Actualizar condición después del movimiento
        condicion.despuesDeMoverse(self)
        
        return "Movimiento ejecutado"
    }
    
    method recibirDanio(cantidad) {
        vidaActual = (vidaActual - cantidad).max(0)
    }
    
    method curarse(cantidad) {
        vidaActual = (vidaActual + cantidad).min(vidaMaxima)
    }
    
    method aplicarCondicion(nuevaCondicion) {
        condicion = nuevaCondicion
    }
    
    method agregarMovimiento(movimiento) {
        movimientos.add(movimiento)
    }
    
    override method toString() = nombre + " (❤️" + vidaActual + "/" + vidaMaxima + ")"
}

///////////////  MOVIMIENTOS ///////////////

class Movimiento {
    const property nombre
    var property usosRestantes
    
    method puedeUsarse() = usosRestantes > 0
    
    method decrementarUsos() {
        if (usosRestantes > 0) {
            usosRestantes -= 1
        }
    }
    
    // PUNTO 2.1: Usar movimiento
    method usar(atacante, objetivo) {
        self.decrementarUsos()
        self.aplicarEfecto(atacante, objetivo)
    }
    
    // Métodos abstractos que implementan las subclases
    method aplicarEfecto(atacante, objetivo)
    method poder()
}

// Movimientos curativos
class MovimientoCurativo inherits Movimiento {
    const property puntosCuracion
    
    override method aplicarEfecto(atacante, objetivo) {
        atacante.curarse(puntosCuracion)
    }
    
    override method poder() = puntosCuracion
}

// Movimientos dañinos
class MovimientoDanino inherits Movimiento {
    const property danio
    
    override method aplicarEfecto(atacante, objetivo) {
        objetivo.recibirDanio(danio)
    }
    
    override method poder() = danio * 2  // Doble del daño
}

// Movimientos especiales
class MovimientoEspecial inherits Movimiento {
    const property condicionAplicar
    
    override method aplicarEfecto(atacante, objetivo) {
        objetivo.aplicarCondicion(condicionAplicar.crearNuevaInstancia())
    }
    
    override method poder() = condicionAplicar.valorPoder()
}

///////////////  CONDICIONES ESPECIALES ///////////////

class Condicion {
    method permiteMoverse() = true
    method despuesDeMoverse(pokemon) { }  // Por defecto no hace nada
    method alNoPoderMoverse(pokemon) { }  // Por defecto no hace nada
    method valorPoder() = 0
    method crearNuevaInstancia() = new CondicionNormal()
}

class CondicionNormal inherits Condicion {
    // Comportamiento por defecto (siempre puede moverse)
}

class CondicionParalisis inherits Condicion {
    override method permiteMoverse() = self.tirarMoneda()
    
    // La parálisis persiste incluso después de moverse
    override method despuesDeMoverse(pokemon) {
        // No se normaliza, sigue paralizado
    }
    
    override method valorPoder() = 30
    
    override method crearNuevaInstancia() = new CondicionParalisis()
    
    method tirarMoneda() = 0.randomUpTo(2).roundUp().even()
}

class CondicionSuenio inherits Condicion {
    override method permiteMoverse() = self.tirarMoneda()
    
    // Si logra moverse, se normaliza
    override method despuesDeMoverse(pokemon) {
        pokemon.aplicarCondicion(new CondicionNormal())
    }
    
    override method valorPoder() = 50
    
    override method crearNuevaInstancia() = new CondicionSuenio()
    
    method tirarMoneda() = 0.randomUpTo(2).roundUp().even()
}

// PUNTO 3: Nueva condición - Confusión
class CondicionConfusion inherits Condicion {
    var property turnosRestantes
    
    override method permiteMoverse() = self.tirarMoneda()
    
    override method despuesDeMoverse(pokemon) {
        turnosRestantes -= 1
        if (turnosRestantes <= 0) {
            pokemon.aplicarCondicion(new CondicionNormal())
        }
    }
    
    override method alNoPoderMoverse(pokemon) {
        // Se hace daño a sí mismo por 20 puntos
        pokemon.recibirDanio(20)
        turnosRestantes -= 1
        if (turnosRestantes <= 0) {
            pokemon.aplicarCondicion(new CondicionNormal())
        }
    }
    
    override method valorPoder() = 40 * turnosRestantes
    
    override method crearNuevaInstancia() = new CondicionConfusion(turnosRestantes = turnosRestantes)
    
    method tirarMoneda() = 0.randomUpTo(2).roundUp().even()
}

///////////////  FACTORY PARA CREAR POKÉMON Y MOVIMIENTOS ///////////////

object fabrica {
    method crearPokemon(nombre, vidaMaxima) = new Pokemon(nombre = nombre, vidaMaxima = vidaMaxima)
    
    method movimientoCurativo(nombre, usos, curacion) = 
        new MovimientoCurativo(nombre = nombre, usosRestantes = usos, puntosCuracion = curacion)
    
    method movimientoDanino(nombre, usos, danio) = 
        new MovimientoDanino(nombre = nombre, usosRestantes = usos, danio = danio)
    
    method movimientoParalizar(nombre, usos) = 
        new MovimientoEspecial(nombre = nombre, usosRestantes = usos, condicionAplicar = new CondicionParalisis())
    
    method movimientoDormir(nombre, usos) = 
        new MovimientoEspecial(nombre = nombre, usosRestantes = usos, condicionAplicar = new CondicionSuenio())
    
    method movimientoConfundir(nombre, usos, turnos) = 
        new MovimientoEspecial(nombre = nombre, usosRestantes = usos, condicionAplicar = new CondicionConfusion(turnosRestantes = turnos))
}

///////////////  POKÉMON ESPECÍFICOS PARA TESTING ///////////////

object pikachu {
    const pokemon = fabrica.crearPokemon("Pikachu", 100)
    
    method initialize() {
        pokemon.agregarMovimiento(fabrica.movimientoDanino("Impactrueno", 5, 25))
        pokemon.agregarMovimiento(fabrica.movimientoParalizar("Onda Trueno", 3))
        pokemon.agregarMovimiento(fabrica.movimientoCurativo("Descanso", 2, 30))
    }
    
    method pokemon() = pokemon
}

object charizard {
    const pokemon = fabrica.crearPokemon("Charizard", 120)
    
    method initialize() {
        pokemon.agregarMovimiento(fabrica.movimientoDanino("Lanzallamas", 4, 35))
        pokemon.agregarMovimiento(fabrica.movimientoDormir("Bostezo", 2))
        pokemon.agregarMovimiento(fabrica.movimientoConfundir("Confusión", 3, 3))
    }
    
    method pokemon() = pokemon
}