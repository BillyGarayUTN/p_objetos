// Sistema RateMe

///////////////  USUARIO ///////////////

class Usuario {
    const property nombre
    var property calificacionGlobal = 3.0  // Empieza en el medio (1-5)
    var property acciones = []
    
    // PUNTO 1a: Saber si puede realizar una acción
    method puedeRealizar(accion) = accion.puedeSerRealizadaPor(self)
    
    // PUNTO 1b: Calificación hipotética que daría
    method calificacionHipotetica(otroUsuario, actividad) {
        const aprueba = evaluadorDeAccion.aprueba(self, actividad, otroUsuario)
        const porcentaje = if (aprueba) 0.10 else -0.12
        return calificacionGlobal * porcentaje
    }
    
    // PUNTO 1c: Calificar a otro usuario por una acción
    method calificar(otroUsuario, actividad) {
        const incremento = self.calificacionHipotetica(otroUsuario, actividad)
        otroUsuario.recibirCalificacion(incremento)
    }
    
    method recibirCalificacion(incremento) {
        calificacionGlobal = (calificacionGlobal + incremento).max(1).min(5)
    }
    
    // PUNTO 2: Realizar una acción
    method realizar(accion) {
        if (self.puedeRealizar(accion)) {
            acciones.add(accion)
            accion.serRealizadaPor(self)
            return "Acción realizada: " + accion.nombre()
        } else {
            self.error("No puedes realizar esta acción: " + accion.nombre())
        }
    }
    
    // PUNTO 4: Acción más popular realizada
    method accionMasPopular() {
        if (acciones.isEmpty()) {
            self.error("No has realizado ninguna acción")
        }
        return acciones.max { accion => accion.popularidad() }
    }
    
    method cantidadAcciones() = acciones.size()
    
    override method toString() = nombre + " (★" + calificacionGlobal + ")"
}

///////////////  ACCIONES ///////////////

class Accion {
    method nombre()
    method puedeSerRealizadaPor(usuario)
    method serRealizadaPor(usuario)
    method popularidad()
}

///////////////  EVENTOS ///////////////

class Evento inherits Accion {
    method calificacionMinima()
    
    override method puedeSerRealizadaPor(usuario) = 
        usuario.calificacionGlobal() >= self.calificacionMinima()
    
    override method serRealizadaPor(usuario) {
        // Los eventos no generan calificaciones
    }
    
    override method popularidad() = self.calificacionMinima()
}

class Cumpleanios inherits Evento {
    override method nombre() = "Cumpleaños"
    override method calificacionMinima() = 2.0
}

class Casamiento inherits Evento {
    override method nombre() = "Casamiento"
    override method calificacionMinima() = 4.0
}

class AfterOffice inherits Evento {
    override method nombre() = "After Office"
    override method calificacionMinima() = 3.0
}

class MeetUp inherits Evento {
    override method nombre() = "Meet-up"
    override method calificacionMinima() = 3.5
}

///////////////  ACTIVIDADES ///////////////

class Actividad inherits Accion {
    var property interesados = []  // Usuarios interesados en calificar
    
    override method puedeSerRealizadaPor(usuario) = true  // Cualquiera puede hacer actividades
    
    override method serRealizadaPor(usuario) {
        // Los interesados califican al usuario que realizó la actividad
        interesados.forEach { interesado => 
            interesado.calificar(usuario, self)
        }
    }
    
    override method popularidad() = 
        interesados.sum { interesado => interesado.calificacionHipotetica(null, self).abs() }
    
    method agregarInteresado(usuario) {
        interesados.add(usuario)
    }
}

class DefenderAlguien inherits Actividad {
    override method nombre() = "Defender a alguien"
}

class Elogiar inherits Actividad {
    override method nombre() = "Elogiar"
}

class HacerBroma inherits Actividad {
    override method nombre() = "Hacer una broma"
}

class Criticar inherits Actividad {
    override method nombre() = "Criticar"
}

///////////////  EVALUADOR DE ACCIÓN ///////////////

object evaluadorDeAccion {
    // Lógica externa ya implementada
    method aprueba(calificador, accion, calificado) {
        // Implementación externa - simulamos diferentes casos
        return true  // Por simplicidad, siempre aprueba
    }
}

///////////////  FAMOSITOS ///////////////

class Famosito inherits Usuario {
    var property criterio
    
    // PUNTO 5b: Calificar según criterio específico
    override method calificar(otroUsuario, actividad) {
        const aprueba = criterio.aprueba(self, otroUsuario)
        const porcentaje = if (aprueba) 0.10 else -0.12
        const incremento = calificacionGlobal * porcentaje
        otroUsuario.recibirCalificacion(incremento)
    }
    
    override method calificacionHipotetica(otroUsuario, actividad) {
        const aprueba = criterio.aprueba(self, otroUsuario)
        const porcentaje = if (aprueba) 0.10 else -0.12
        return calificacionGlobal * porcentaje
    }
    
    method cambiarCriterio(nuevoCriterio) {
        criterio = nuevoCriterio
    }
}

///////////////  CRITERIOS DE FAMOSITOS ///////////////

class Criterio {
    method aprueba(famosito, otroUsuario)
}

class Admiracion inherits Criterio {
    override method aprueba(famosito, otroUsuario) {
        if (otroUsuario.acciones().isEmpty()) {
            return false  // No tiene acciones para evaluar
        }
        
        const accionMasPopular = otroUsuario.accionMasPopular()
        return accionMasPopular.popularidad() > famosito.calificacionGlobal()
    }
}

class Envidia inherits Criterio {
    override method aprueba(famosito, otroUsuario) {
        return otroUsuario.cantidadAcciones() <= famosito.cantidadAcciones()
    }
}

///////////////  SISTEMA RATEME ///////////////

object sistemaRateMe {
    
    // PUNTO 3: Usuarios que pueden realizar una acción
    method usuariosQuePueden(listaUsuarios, accion) = 
        listaUsuarios.filter { usuario => usuario.puedeRealizar(accion) }
    
    // PUNTO 6: Simular itinerario
    method simularItinerario(usuario, acciones) {
        const usuarioCopia = usuario.copy()
        
        acciones.forEach { accion =>
            if (usuarioCopia.puedeRealizar(accion)) {
                usuarioCopia.realizar(accion)
            }
        }
        
        return usuarioCopia
    }
    
    // Métodos auxiliares
    method crearUsuario(nombre) = new Usuario(nombre = nombre)
    
    method crearFamosito(nombre, criterio) = 
        new Famosito(nombre = nombre, criterio = criterio)
}