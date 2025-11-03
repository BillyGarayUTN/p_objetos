// Actores considerados "grosos" para el cálculo de precio en Drama
// Según enunciado: Diego Peretti, Leo Sbaraglia, Julieta Zylberberg, Rita Cortese y Ricardo Darín
const actoresGroso = ["Diego Peretti", "Leo Sbaraglia", "Julieta Zylberberg", "Rita Cortese", "Ricardo Darín"]

// Clase para modelar las funciones con fecha y hora
class Funcion {
    const property fecha
    const property hora   // numero entero (formato 24hs, ej: 18 para las 18:00)
    
    method initialize() {
        // Validaciones opcionales si necesitas
        if (fecha == null || hora == null) {
            self.error("La función debe tener fecha y hora")
        }
        if (hora < 0 || hora > 23) {
            self.error("La hora debe estar entre 0 y 23")
        }
    }

    // Precio base: $120 si es fin de semana, $80 si no
    method precioBase() = if(fecha.isWeekendDay()) 120 else 80
    
    // Adicional de $20 si es después de las 18 horas
    method adicionalPorHorario() = if(hora >= 18) 20 else 0
    
    // Precio total de la función
    method precioFuncion() = self.precioBase() + self.adicionalPorHorario()
}

class Rodaje{
    method precioBase
    var property genero 
    var property funciones = []  // Lista de objetos Funcion

    // Fórmula de precio: $50 base + precio base específico + adicional por género
    method precio() = 50 + self.precioBase() + genero.precioPorGenero(self)
    
    // Método para agregar funciones al rodaje
    method agregarFuncion(funcion) {
        funciones.add(funcion)
    }
    
    // Cantidad de funciones disponibles (para determinar si es taquillero)
    method cantidadFunciones() = funciones.size()
    
    // Un rodaje es taquillero si tiene más de 50 funciones disponibles
    method esTaquillero() = self.cantidadFunciones() > 50
}


class Pelicula inherits Rodaje{    
    const calificacion

    // Validación: calificación debe estar entre 0 y 10
    method initialize() {
        if (calificacion < 0 || calificacion > 10) {
            self.error("La calificación debe estar entre 0 y 10")
        }
    }

    override method precioBase() = if(self.buenaCalificacion()) 50 else 30

    method buenaCalificacion() = calificacion > 7
}

class Saga inherits Rodaje {
    const plusPorFanatismo
    
    var property peliculas = []

    // Validación: una saga debe tener al menos una película
    method agregarPelicula(pelicula) {
        peliculas.add(pelicula)
    }

    override method precioBase() {
        if (peliculas.isEmpty()) {
            self.error("Una saga debe tener al menos una película")
        }
        return peliculas.size() * 10 + plusPorFanatismo
    }

}
//////////////////// Géneros ////////////////////    

// Género Acción: $100 si es taquillero (>50 funciones), $50 caso contrario
class Accion{

    method precioPorGenero(rodaje) = if (rodaje.esTaquillero()) 100 else 50

}

// Género Terror: Siempre aporta $50 (no corta ni pincha)
class Terror {

    method precioPorGenero(rodaje) = 50

}

// Género Drama: $95 si tiene actor "groso", $20 caso contrario
// Nota: El enunciado menciona "personaje principal gordo" pero se implementa
// como verificación de actores "grosos" en el reparto
class Drama{
    var property actores = []

    method precioPorGenero(rodaje) = if (self.esGroso()) 95 else 20

    // Verifica si algún actor del reparto está en la lista de actores grosos
    method esGroso() = actores.any{actor => actoresGroso.contains(actor)}
}

class Entrada{
    const property rodaje
    const property funcion
    
    // El precio de la entrada es: precio del rodaje + precio de la función
    method precio() = rodaje.precio() + funcion.precioFuncion()
}

class Usuario {
    var property saldo = 100  // Los usuarios inician con $100 por asociarse
    var property entradas = []  // Entradas compradas por el usuario
    
    // Método principal para sacar una entrada
    method sacarEntrada(rodaje, funcion) {
        // Validaciones en orden de prioridad
        self.validarFechaFuncion(funcion)
        self.validarRodajeTieneFuncion(rodaje, funcion)
        
        const entrada = new Entrada(rodaje = rodaje, funcion = funcion)
        self.validarSaldoSuficiente(entrada)
        
        // Si llegamos acá, todas las validaciones pasaron
        self.procesarCompra(entrada)
        return entrada
    }
    
    // Validar que la función no sea de un día anterior al de hoy
    method validarFechaFuncion(funcion) {
        const hoy = new Date()
        if (funcion.fecha() < hoy) {
            self.error("No se puede comprar una entrada para una función de fecha anterior a hoy")
        }
    }
    
    // Validar que el rodaje tenga la función especificada (mismo día y hora)
    method validarRodajeTieneFuncion(rodaje, funcion) {
        const funcionCorrecta = rodaje.funciones().any { f => 
            f.fecha() == funcion.fecha() && f.hora() == funcion.hora()
        }
        if (!funcionCorrecta) {
            self.error("El rodaje no tiene una función en la fecha y hora especificadas")
        }
    }
    
    // Validar que el usuario tenga suficiente saldo
    method validarSaldoSuficiente(entrada) {
        if (saldo < entrada.precio()) {
            self.error("Saldo insuficiente. Precio: $" + entrada.precio() + ", Saldo disponible: $" + saldo)
        }
    }
    
    // Procesar la compra: descontar saldo y agregar entrada
    method procesarCompra(entrada) {
        saldo = saldo - entrada.precio()
        entradas.add(entrada)
    }
    
    // Método para agregar saldo (útil para testing)
    method cargarSaldo(importe) {
        saldo = saldo + importe
    }
    
    // PUNTO 5: Cuánto gastó el usuario en entradas
    method totalGastado() = entradas.sum { entrada => entrada.precio() }
    
    // PUNTO 5: Si el usuario es fanático (alguna entrada cuesta más de $300)
    method esFanatico() = entradas.any { entrada => entrada.precio() > 300 }
    
}