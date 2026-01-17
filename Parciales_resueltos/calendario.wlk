// Objeto Calendario para manejo centralizado de fechas

object calendario {
    
    // Obtener fecha actual
    method hoy() = new Date()
    
    // Verificar si es fin de semana
    method esFinDeSemana(fecha) = fecha.isWeekendDay()
    
    // Verificar si una fecha es anterior a otra
    method esAnterior(fecha1, fecha2) = fecha1 < fecha2
    
    // Verificar si una fecha es posterior a otra  
    method esPosterior(fecha1, fecha2) = fecha1 > fecha2
    
    // Verificar si dos fechas son el mismo día
    method mismoDia(fecha1, fecha2) = fecha1 == fecha2
    
    // Validar que una fecha no sea pasada
    method validarFechaFutura(fecha) {
        if (self.esAnterior(fecha, self.hoy())) {
            self.error("La fecha no puede ser anterior a hoy")
        }
    }
    
    // Validar rango de fechas
    method validarRango(fechaInicio, fechaFin) {
        if (self.esPosterior(fechaInicio, fechaFin)) {
            self.error("La fecha de inicio no puede ser posterior a la fecha de fin")
        }
    }
    
    // Método práctico: solo fecha actual (lo más usado en Wollok)
    method nuevaFecha() = new Date()
    
    
    // Calcular diferencia en días (aproximada)
    method diasEntre(fechaInicio, fechaFin) {
        // Wollok tiene métodos para esto, pero aquí un ejemplo básico
        return (fechaFin - fechaInicio).days()
    }
    
    // Verificar si la fecha está en un período específico
    method estaEnPeriodo(fecha, fechaInicio, fechaFin) = 
        !self.esAnterior(fecha, fechaInicio) && !self.esPosterior(fecha, fechaFin)
    
    // Formatear fecha para mostrar (si necesitas)
    method formatear(fecha) = fecha.toString()
}

// Ejemplo de uso del calendario
class EventoConFecha {
    const property nombre
    const property fecha
    
    method initialize() {
        calendario.validarFechaFutura(fecha)
    }
    
    method esEnFinDeSemana() = calendario.esFinDeSemana(fecha)
    
    method yaOcurrio() = calendario.esAnterior(fecha, calendario.hoy())
    
    method esHoy() = calendario.mismoDia(fecha, calendario.hoy())
    
    override method toString() = 
        nombre + " (" + calendario.formatear(fecha) + ")"
}

// Ejemplo de gestión de períodos
class PeriodoAcademico {
    const property fechaInicio
    const property fechaFin
    
    method initialize() {
        calendario.validarRango(fechaInicio, fechaFin)
    }
    
    method estaEnCurso() = 
        calendario.estaEnPeriodo(calendario.hoy(), fechaInicio, fechaFin)
    
    method duracionDias() = 
        calendario.diasEntre(fechaInicio, fechaFin)
    
    method yaTermino() = 
        calendario.esPosterior(calendario.hoy(), fechaFin)
}

// Objetos mock para testing (simulan fechas específicas)
object fechaMockSabado {
    method isWeekendDay() = true
    override method toString() = "Sábado (Mock)"
}

object fechaMockLunes {
    method isWeekendDay() = false  
    override method toString() = "Lunes (Mock)"
}

// Tests para el calendario
object testCalendario {
    
    method testValidaciones() {
        const hoy = calendario.hoy()
        
        // Test fin de semana
        console.println("Hoy es fin de semana: " + calendario.esFinDeSemana(hoy))
        
        // Test con fecha mock
        console.println("Sábado es fin de semana: " + calendario.esFinDeSemana(fechaMockSabado))
        console.println("Lunes es fin de semana: " + calendario.esFinDeSemana(fechaMockLunes))
        
        // Test evento con fecha actual
        const evento = new EventoConFecha(
            nombre = "Parcial PDP",
            fecha = hoy
        )
        
        console.println("Evento: " + evento.toString())
        console.println("Es hoy: " + evento.esHoy())
        console.println("Ya ocurrió: " + evento.yaOcurrio())
    }
}