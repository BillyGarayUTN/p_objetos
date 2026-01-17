class Cliente {
    var property nombre 
    var property dni
    var property historialCompras = []  // Lista de Compras
    var property tipo  // comun, silver, gold (polimórfico)

    // Delegar al tipo el cálculo del descuento
    method descuentoEnvio() = tipo.descuento(self)

    // Realizar una compra (validando stock del local)
    method realizarCompra(pedido) {
        // Verificar que el local tenga todos los productos
        if (!pedido.local().tieneTodosLosProductos(pedido)) {
            throw new DomainException(message = "El local no tiene todos los productos del pedido")
        }
        
        // Crear la compra
        const compra = new Compra(
            pedido = pedido,
            valorEnvio = pedido.costoEnvio(),
            fecha = new Date()
        )
        
        historialCompras.add(compra)
        return compra
    }

    // Compra más cara (mayor precio total)
    method compraMasCara() = historialCompras.max({ compra => compra.total() })

    // Monto total ahorrado en envíos (diferencia entre costo real y pagado)
    method montoTotalAhorrado() = historialCompras.sum({ compra => compra.ahorroEnvio() })

    // Producto más caro comprado (según precio unitario)
    method productoMasCaro() {
        const todosLosItems = historialCompras.flatMap({ compra => compra.pedido().items() })
        return todosLosItems.max({ item => item.producto().precio() }).producto()
    }

    // Producto de mayor cantidad comprada en un mismo pedido
    method productoMayorCantidad() {
        const todosLosItems = historialCompras.flatMap({ compra => compra.pedido().items() })
        return todosLosItems.max({ item => item.cantidad() }).producto()
    }
}

// ===== TIPOS DE CLIENTES (POLIMORFISMO) =====

object comun {
    // Sin descuento - paga el 100%
    method descuento(cliente) = 1
}

object silver {
    // Paga el 50% del envío
    method descuento(cliente) = 0.5
}

object gold {
    // Paga el 10% del envío, pero cada 5 compras no paga
    method descuento(cliente) {
        const cantidadCompras = cliente.historialCompras().size()
        return if (cantidadCompras % 5 == 0 && cantidadCompras > 0) 0 else 0.1
    }
}

// ===== PEDIDO =====

class Pedido {
    var property items = []  // Lista de Item
    var property cliente
    var property local

    // Agregar producto al pedido (incrementa si ya existe)
    method agregar(producto, cantidad) {
        const itemExistente = items.find({ item => item.producto() == producto })
        
        if (itemExistente != null) {
            itemExistente.cantidad(itemExistente.cantidad() + cantidad)
        } else {
            items.add(new Item(producto = producto, cantidad = cantidad))
        }
    }

    // Obtener todos los productos del pedido
    method productosDelPedido() = items.map({ item => item.producto() })

    // Precio sin considerar envío
    method precioBruto() = items.sum { i => i.precioItem() }

    // Precio final que paga el cliente
    method precioNeto() = self.precioBruto() + self.costoEnvio()

    // Costo REAL de envío (sin descuentos) - $15 por cuadra, tope $300
    method costoRealEnvio() {
        const cuadras = calculador.calcularDistancia(cliente, local)
        return (cuadras * 15).min(300)
    }

    // Costo de envío que paga el cliente (con descuento según tipo)
    method costoEnvio() = self.costoRealEnvio() * cliente.descuentoEnvio()
}

// ===== ITEM =====

class Item {
    var property producto
    var property cantidad

    // Precio total del item (producto * cantidad)
    method precioItem() = producto.precio() * cantidad
}

// ===== PRODUCTO =====

class Producto {
    var property precio
}

// ===== CALCULADOR (MÓDULO EXTERNO) =====

object calculador {
    // Módulo comprado - solo representamos la interfaz
    method calcularDistancia(cliente, local) {
        // Retorna cantidad de cuadras entre cliente y local
        return 20  // Valor de prueba
    }
}

// ===== COMPRA =====

class Compra {
    var property pedido
    var property valorEnvio
    var property fecha

    // Total de la compra (precio bruto + envío)
    method total() = pedido.precioBruto() + valorEnvio

    // Ahorro en envío (diferencia entre costo real y lo que pagó)
    method ahorroEnvio() = pedido.costoRealEnvio() - valorEnvio
}

// ===== LOCAL =====

class Local {
    var property productos = []  // Lista de productos disponibles

    // Verificar si tiene todos los productos de un pedido
    method tieneTodosLosProductos(pedido) {
        return pedido.productosDelPedido().all({ producto => 
            productos.contains(producto) 
        })
    }
}

