class HayPocosEmpleados inherits Exception {
  
}

class NoHayPlata inherits Exception {
  
}

class Sucursal {
  var property empleados = []
  const presupuesto = 1320
  
  method esViable() = empleados.sum({ un => un.sueldo() }) <= presupuesto
  
  method trasnferirEmpleadoA(empleado, nuevaSucursal) {
    if (!nuevaSucursal.esViable()) {
      throw new NoHayPlata(
        message = "no es posible trasnferir al empleado porque no hay plata"
      )
    }
    
    if (self.pocaGente()) {
      throw new HayPocosEmpleados(
        message = "no es posible trasnferir al empleado porque hay poca gente"
      )
    }
    
    nuevaSucursal.empleados().add(empleado)
    empleados.remove(empleado)
    empleado.sucursal(nuevaSucursal)
  }
  
  method pocaGente() = self.empleados().size() < 4
}

class Empleado {
  var property sucursal
  var property antiguedad
  var property cargo
  
  method cambiarCargo(nuevoCargo) {
    cargo = nuevoCargo
  } // redundante
  
  method sueldo() = cargo.sueldoBase(self) + (100 * antiguedad)
  
  method colegas() = sucursal.empleados().size() - 1
}

class Cargo {
  var horasTrabajadasPorDia
  
  method initialize() {
    if (!horasTrabajadasPorDia.between(4, 8)) {
      throw new DomainException(message = "Las horas deben ser entre 4 y 8")
    }
  }
  
  method diasLaborables() = 22
  
  method sueldoBase(empleado) = (self.sueldoPorHoraDelCargo(
    empleado
  ) * horasTrabajadasPorDia) * self.diasLaborables()
  
  method sueldoPorHoraDelCargo(empleado)
}

class Recepcionista inherits Cargo {
  override method sueldoPorHoraDelCargo(empleado) = 15
}

class Pasante inherits Cargo {
  var diasDeEstudio
  
  override method diasLaborables() = super() - diasDeEstudio
  
  override method sueldoPorHoraDelCargo(empleado) = 10
}

class Gerente inherits Cargo {
  const property plus = 0
  
  override method sueldoPorHoraDelCargo(
    empleado
  ) = (8 * empleado.colegas()) + self.plus()
}

class VicepresidenteJunior inherits Gerente {
  override method sueldoPorHoraDelCargo(empleado) = super(empleado) * 1.03
}