class Rodaje{
    var property precioBase

    var property genero 

    method precio() = 50 + precioBase + genero.precio()

}


class Pelicula inherits Rodaje{    
    const calificacion

    method precioBase() = if(self.buenaCalificacion()) 50 else 30

    method buenaCalificacion() = calificacion > 7
    
}

class Saga inherits Rodaje {
    const plusPorFanatismo
    
    var property capitulos = []

    method precioBase() = capitulos.size() * 10 + plusPorFanatismo

}












