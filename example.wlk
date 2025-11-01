// Actores considerados "grosos" para el cálculo de precio en Drama
// Según enunciado: Diego Peretti, Leo Sbaraglia, Julieta Zylberberg, Rita Cortese y Ricardo Darín
const actoresGroso = ["Diego Peretti", "Leo Sbaraglia", "Julieta Zylberberg", "Rita Cortese", "Ricardo Darín"]

class Rodaje{
    var property precioBase
    var property genero 

    // Fórmula de precio: $50 base + precio base específico + adicional por género
    method precio() = 50 + precioBase + genero.precioPorGenero()
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
    const funcionesDisponibles

    method precioPorGenero() = if ( self.esTaquillero() ) 100 else 50

    // Un rodaje es taquillero si tiene más de 50 funciones disponibles
    method esTaquillero() = funcionesDisponibles > 50 

}

// Género Terror: Siempre aporta $50 (no corta ni pincha)
class Terror {

    method precioPorGenero() = 50

}

// Género Drama: $95 si tiene actor "groso", $20 caso contrario
// Nota: El enunciado menciona "personaje principal gordo" pero se implementa
// como verificación de actores "grosos" en el reparto
class Drama{
    var property actores = []

    method precioPorGenero() = if (self.esGroso()) 95 else 20

    // Verifica si algún actor del reparto está en la lista de actores grosos
    method esGroso() = actores.any{actor => actoresGroso.contains(actor)}
}



