class NoPuedeAtenderse inherits Exception{}

class Animal{
    var property peso = 0
    var property sed = false

    method come(cantidad){}
    method bebe(){}
    method hambre()
}


object vaca inherits Animal{

    override method come(cantidad) {
    peso = (peso + (cantidad / 3)).max(0)
    sed = true
    }

    override method bebe() {
    sed = false
    peso = (peso - 0.5).max(0)
    }

    override method hambre() = peso < 200
}

// ===== Cerdo =====
class Cerdo inherits Animal {
    var hambre = true
    var comidasDesdeUltimaBebida = 0

    override method come(cantidad) {
    if (cantidad > 0.2) {
        peso = peso + (cantidad - 0.2)
    }
    if (cantidad > 1) {
        hambre = false
    }
    comidasDesdeUltimaBebida += 1
    }

    override method bebe() {
    hambre = true                  // "cuando bebe le da hambre"
    comidasDesdeUltimaBebida = 0   // reinicia el conteo para la sed
    }

    override method hambre() = hambre
    override method sed() = comidasDesdeUltimaBebida > 3
}

object gallina inherits Animal (peso=4, sed=false){

    override method hambre() = true

    override method sed() = false

}

class Bebedero {
    method esUtilPara(animal) = animal.tieneSed()
    method atender(animal) { animal.bebe() }
}

class Comedero {
  const property cantidadFija         // kg que entrega
  const property soporteMaxKg         // peso máximo soportado

    method esUtilPara(animal) =
    animal.tieneHambre() && animal.peso() <= soporteMaxKg

    method atender(animal) {
    if (animal.peso() > soporteMaxKg) {
        throw new NoPuedeAtenderse(message = "Sobrepeso: el comedero no lo soporta")
    }
    if (animal.tieneHambre()) {
        animal.come(cantidadFija)
    }
    }
}