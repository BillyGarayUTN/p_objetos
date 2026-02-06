class Personaje {
    const rol
    
    const fuerza

    var property inteligencia

    method potencialOfensivo() = fuerza * 10 + rol.potencialOfensivo()

    method esGroso() = self.esInteligente() && rol.esGrosoEnSuRol(self)

    method esInteligente()

    method fuerzaMayora50() = fuerza > 50
}

/////////////////////// Razas /////////////////////////
class Orco inherits Personaje {
    override method potencialOfensivo() = super()*1.1

    override method esInteligente() = false
}

class Humano inherits Personaje {
    
    override method esInteligente() = inteligencia > 50 
}

//////////////// ROLES   ///////////
class Guerrero {
    method potencialOfensivo() = 100

    method esGrosoEnSuRol(personaje) = personaje.fuerzaMayora50()
}

class Cazador {
    const mascota

    method potencialOfensivo() = mascota.potencialOfensivo()

    method esGrosoEnSuRol(personaje) = mascota.esLongeva()
}

class Brujo {
    method potencialOfensivo() = 0

    method esGrosoEnSuRol(personaje) = true
}

class Mascota{
    const fuerza

    const edad

    const tieneGarras

    method potencialOfensivo() = if(tieneGarras ) fuerza*2 else fuerza

    method esLongeva() = edad > 10
}

/////////////   LUGARES    ////////////
class Zona{
    var habitantes = []

    method potencialDfensivo() = habitantes.sum{ un=> un.potencialOfensivo()}
    method seOcupadaPor(ejercito) { habitantes = ejercito}
}
class Aldea inherits Zona{
    const maxHabitantes  = 50 

    override method seOcupadaPor(ejercito) {
    if(ejercito.miembros().size() > maxHabitantes){
        const nuevosHabitantess = ejercito.miembros()
        .sortedBy{un,otro=> un.potencialOfensivo() > otro.potencialOfensivo()}
        .take(10)

        super(new Ejercito(miembros = nuevosHabitantess))
        ejercito.miembros().removeAll(nuevosHabitantess)
        }else super(ejercito)
    }
}   

class Ciudad inherits Zona{
    override  method potencialDfensivo() = super() + 300
}
class Ejercito{

    var property miembros = []

    method potencialOfensivo() = miembros.sum{ un=> un.potencialOfensivo()}

    method invadir(zona) {
        if(zona.potencialDfensivo() < self.potencialOfensivo()){
            zona.seOcupadaPor(self)
        }
    }
}

