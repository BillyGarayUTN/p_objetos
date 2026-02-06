// Excepciones
class FuncionPasadaException inherits Exception {}
class FuncionNoDisponibleException inherits Exception {}
class SaldoInsuficienteException inherits Exception {}

const actoresGrosos = ["peretti", "sbaraglia", "zylberberg", "cortese", "darin"]
class Rodaje{
    var property personajePrincipal

    var property genero

    var property funciones = []

    // punto 1
    method precio() = 50 + self.precioBase() + genero.adicionalPorGenero(self)

    method precioBase()

    method esTaquillero() = funciones.size() > 50

    method actorPrincipalGroso() = actoresGrosos.contains(personajePrincipal)
    
    method tieneFuncion(funcion) = funciones.any{f => f.coincideCon(funcion)}

}

class Pelicula inherits Rodaje{
    const property puntuacion

    method buenaCalificacion() = puntuacion > 7 

    override method precioBase() = if(self.buenaCalificacion()) 50 else 30
}

class Saga inherits Rodaje{
    const property plus

    var property peliculas = []

    override method precioBase() = 10 * peliculas.size() + plus

}

class Funcion{
    const property fecha
    const property hora

    method precioFuncion() = self.aLaTarde() + if(fecha.isWeekendDay()) 120  else  80 

    method aLaTarde() = if(hora >= 18) 20 else 0
    
    method esPasada() = fecha < new Date()
    
    method coincideCon(otraFuncion) = fecha == otraFuncion.fecha() && hora == otraFuncion.hora()
}

// generos 77
class Accion{
    method adicionalPorGenero(rodaje) = if(rodaje.esTaquillero()) 100 else 50 
}

class Terror{
    method adicionalPorGenero(rodaje) = 50
}

class Drama{
    method adicionalPorGenero(rodaje) = if(rodaje.actorPrincipalGroso()) 95 else 20
}

class Entrada{

    const property rodaje
    const property funcion

    method precioEntrada() = rodaje.precio() + funcion.precioFuncion()
}

class Usuario{
    var property saldo = 100
    const property entradas = []
    
    method sacarEntrada(rodaje, funcion) {
        self.validarFuncion(funcion)
        self.validarRodajeTieneFuncion(rodaje, funcion)
        
        const entrada = new Entrada(rodaje = rodaje, funcion = funcion)
        
        self.validarSaldo(entrada)
        
        saldo = saldo - entrada.precioEntrada()
        entradas.add(entrada)
    }
    
    method validarFuncion(funcion) {
        if(funcion.esPasada()) {
            throw new FuncionPasadaException(message = "La función es de un día anterior al de hoy")
        }
    }
    
    method validarRodajeTieneFuncion(rodaje, funcion) {
        if(!rodaje.tieneFuncion(funcion)) {
            throw new FuncionNoDisponibleException(message = "El rodaje no tiene esa función disponible")
        }
    }
    
    method validarSaldo(entrada) {
        if(saldo < entrada.precioEntrada()) {
            throw new SaldoInsuficienteException(message = "No tiene suficiente dinero para comprar la entrada")
        }
    }
    
    // Punto 5
    method totalGastado() = entradas.sum{unaEntrada => unaEntrada.precioEntrada()}

    method esFanatico() = entradas.any{unaEntrada => unaEntrada.precioEntrada() > 300}
}
