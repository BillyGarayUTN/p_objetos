// Sistema de Super-Computadoras

///////////////  SUPER-COMPUTADORA ///////////////

class SuperComputadora {
    var property equipos = []
    var property complejidadResuelta = 0  // Contador de auditoría
    
    // PUNTO 1a: Equipos activos
    method equiposActivos() = equipos.filter { equipo => equipo.estaActivo() }
    
    // PUNTO 1b: Capacidad de cómputo y consumo total
    method capacidadComputo() = self.equiposActivos().sum { equipo => equipo.capacidadComputo() }
    
    method consumoTotal() = self.equiposActivos().sum { equipo => equipo.consumo() }
    
    // PUNTO 1c: Mal configurada
    method malConfigurada() {
        const activos = self.equiposActivos()
        if (activos.isEmpty()) return false
        
        const equipoQueMasConsume = activos.max { equipo => equipo.consumo() }
        const equipoQueMasComputa = activos.max { equipo => equipo.capacidadComputo() }
        
        return equipoQueMasConsume != equipoQueMasComputa
    }
    
    // PUNTO 2: Computar problema
    method computarProblema(complejidad) {
        const activos = self.equiposActivos()
        
        if (activos.isEmpty()) {
            self.error("No hay equipos activos para computar")
        }
        
        const complejidadPorEquipo = complejidad / activos.size()
        
        // Cada equipo intenta resolver su subproblema
        const resultados = activos.map { equipo => equipo.computar(complejidadPorEquipo) }
        
        // Solo incrementa si TODOS los equipos tuvieron éxito
        if (resultados.all { resultado => resultado }) {
            complejidadResuelta += complejidad
            return "Problema resuelto exitosamente"
        } else {
            return "Fallo en el cómputo - algunos equipos fallaron"
        }
    }
    
    method agregarEquipo(equipo) {
        equipos.add(equipo)
    }
    
    method conectarSuperComputadora(otraSC) {
        equipos.add(otraSC)  // Las SC se tratan como equipos
    }
}

///////////////  EQUIPOS BASE ///////////////

class Equipo {
    var property modo
    var property quemado = false
    
    method estaActivo() = !quemado && self.capacidadComputo() > 0
    
    method capacidadComputo() = modo.capacidadComputo(self)
    
    method consumo() = modo.consumo(self)
    
    method computar(complejidad) = modo.computar(self, complejidad)
    
    method quemarse() {
        quemado = true
    }
    
    method cambiarModo(nuevoModo) {
        modo = nuevoModo
    }
    
    // Métodos abstractos que implementan las subclases
    method consumoBase()
    method capacidadComputoBase()
    method puedeComputar(complejidad)
}

///////////////  TIPOS DE EQUIPOS ///////////////

class EquipoA105 inherits Equipo {
    override method consumoBase() = 300
    
    override method capacidadComputoBase() = 600
    
    override method puedeComputar(complejidad) = complejidad >= 5  // No puede computar < 5
}

class EquipoB2 inherits Equipo {
    var property microchips
    
    override method consumoBase() = (50 * microchips) + 10  // 50 por micro + 10 placa madre
    
    override method capacidadComputoBase() = (100 * microchips).min(800)  // Max 800
    
    override method puedeComputar(complejidad) = true  // Puede computar cualquier complejidad
}

///////////////  MODOS DE FUNCIONAMIENTO ///////////////

class Modo {
    method capacidadComputo(equipo)
    method consumo(equipo)
    method computar(equipo, complejidad)
    
    method puedeResolverProblema(equipo, complejidad) = 
        equipo.puedeComputar(complejidad) && complejidad <= self.capacidadComputo(equipo)
}

class ModoStandard inherits Modo {
    override method capacidadComputo(equipo) = equipo.capacidadComputoBase()
    
    override method consumo(equipo) = equipo.consumoBase()
    
    override method computar(equipo, complejidad) = 
        self.puedeResolverProblema(equipo, complejidad)
}

class ModoOverclock inherits Modo {
    var property usosRestantes = 10.randomUpTo(100).roundUp()  // Número arbitrario
    
    override method capacidadComputo(equipo) = 
        equipo.capacidadComputoBase() + self.bonusOverclock(equipo)
    
    method bonusOverclock(equipo) {
        if (equipo.kindOf(EquipoA105)) {
            return equipo.capacidadComputoBase() * 0.30  // 30% extra
        } else {
            return 20 * equipo.microchips()  // 20 por microchip
        }
    }
    
    override method consumo(equipo) = equipo.consumoBase() * 2  // Doble consumo
    
    override method computar(equipo, complejidad) {
        if (!self.puedeResolverProblema(equipo, complejidad)) {
            return false
        }
        
        usosRestantes -= 1
        
        const seQuemo = usosRestantes <= 0
        if (seQuemo) {
            equipo.quemarse()
        }
        
        return !seQuemo
    }
}

class ModoAhorroEnergia inherits Modo {
    var property intentosComputar = 0
    
    override method capacidadComputo(equipo) = 
        equipo.capacidadComputoBase() * self.factorReduccion(equipo)
    
    method factorReduccion(equipo) = 200 / equipo.consumoBase()  // Proporcional a pérdida energía
    
    override method consumo(equipo) = 200  // Siempre 200 watts
    
    override method computar(equipo, complejidad) {
        if (!self.puedeResolverProblema(equipo, complejidad)) {
            return false
        }
        
        intentosComputar += 1
        
        // Falla 1 de cada 17 intentos por monitor de consumo
        return intentosComputar % 17 != 0
    }
}

// PUNTO 3: Nuevo modo A Prueba de Fallos
class ModoAPruebaFallos inherits Modo {
    var property intentosComputar = 0
    
    override method capacidadComputo(equipo) = 
        equipo.capacidadComputoBase() / 2  // Mitad de capacidad
    
    override method consumo(equipo) = 200  // Mismo consumo que ahorro energía
    
    override method computar(equipo, complejidad) {
        if (!self.puedeResolverProblema(equipo, complejidad)) {
            return false
        }
        
        intentosComputar += 1
        
        // Falla 1 de cada 100 intentos (mejor que ahorro energía)
        return intentosComputar % 100 != 0
    }
}

///////////////  FACTORY PARA CREAR EQUIPOS ///////////////

object fabricaEquipos {
    method crearA105(modo) = new EquipoA105(modo = modo)
    
    method crearB2(microchips, modo) = new EquipoB2(microchips = microchips, modo = modo)
    
    method crearSuperComputadora() = new SuperComputadora()
}

///////////////  FACTORY PARA MODOS ///////////////

object fabricaModos {
    method standard() = new ModoStandard()
    
    method overclock() = new ModoOverclock()
    
    method ahorroEnergia() = new ModoAhorroEnergia()
    
    method aPruebaFallos() = new ModoAPruebaFallos()
}