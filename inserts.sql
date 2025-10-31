-- Asegúrate de estar en el esquema
USE `mrfrito`;

-- Opcional: para facilitar resiembras en dev
SET FOREIGN_KEY_CHECKS = 0;

-- Guarda el id del admin (normalmente será 1)
-- (Si tu cliente/IDE soporta variables):
SET @admin_id = 1;

-- ==============================
-- 2. Canales de venta
-- ==============================
-- Porcentajes de comisión típicos por canal
INSERT INTO `canales`
  (`nombre`,`porcentaje_comision`,`descripcion`,
   `usuario_creacion`,`usuario_modificacion`)
VALUES
  ('Mostrador', 0.00,  'Venta directa en local',       @admin_id, @admin_id),
  ('Rappi',     22.00, 'Delivery por plataforma Rappi', @admin_id, @admin_id),
  ('UberEats',  25.00, 'Delivery por UberEats',         @admin_id, @admin_id),
  ('PedidosYa', 18.00, 'Delivery por PedidosYa',        @admin_id, @admin_id);

-- Guarda IDs para referencia rápida
SET @canal_mostrador = (SELECT id_canal FROM canales WHERE nombre='Mostrador' LIMIT 1);
SET @canal_rappi     = (SELECT id_canal FROM canales WHERE nombre='Rappi' LIMIT 1);
SET @canal_ubereats  = (SELECT id_canal FROM canales WHERE nombre='UberEats' LIMIT 1);
SET @canal_pedidosya = (SELECT id_canal FROM canales WHERE nombre='PedidosYa' LIMIT 1);

-- ==============================
-- 3. Categorías de gasto
-- ==============================
INSERT INTO `categorias_gasto`
  (`nombre`,`tipo`,`descripcion`,`usuario_creacion`,`usuario_modificacion`)
VALUES
  ('Renta local','fijo','Alquiler mensual del local', @admin_id, @admin_id),
  ('Servicios','fijo','Luz, agua, internet',          @admin_id, @admin_id),
  ('Materia prima','variable','Papás, aceites, carnes, panes', @admin_id, @admin_id),
  ('Empaques','variable','Cajas, vasos, servilletas', @admin_id, @admin_id),
  ('Marketing','variable','Ads y promos',             @admin_id, @admin_id),
  ('Sueldos','fijo','Planilla del personal',          @admin_id, @admin_id);

SET @cat_renta         = (SELECT id_categoria FROM categorias_gasto WHERE nombre='Renta local' LIMIT 1);
SET @cat_servicios     = (SELECT id_categoria FROM categorias_gasto WHERE nombre='Servicios' LIMIT 1);
SET @cat_materia_prima = (SELECT id_categoria FROM categorias_gasto WHERE nombre='Materia prima' LIMIT 1);
SET @cat_empaques      = (SELECT id_categoria FROM categorias_gasto WHERE nombre='Empaques' LIMIT 1);
SET @cat_marketing     = (SELECT id_categoria FROM categorias_gasto WHERE nombre='Marketing' LIMIT 1);
SET @cat_sueldos       = (SELECT id_categoria FROM categorias_gasto WHERE nombre='Sueldos' LIMIT 1);

-- ==============================
-- 4. Presupuestos (mes actual)
-- ==============================
-- Ajusta montos según tu realidad
INSERT INTO `presupuestos`
  (`id_categoria`,`fecha_inicio`,`fecha_fin`,`monto_planificado`,
   `usuario_creacion`,`usuario_modificacion`)
VALUES
  (@cat_renta,         DATE_FORMAT(CURDATE(),'%Y-%m-01'), LAST_DAY(CURDATE()), 3000.00, @admin_id, @admin_id),
  (@cat_servicios,     DATE_FORMAT(CURDATE(),'%Y-%m-01'), LAST_DAY(CURDATE()), 1200.00, @admin_id, @admin_id),
  (@cat_materia_prima, DATE_FORMAT(CURDATE(),'%Y-%m-01'), LAST_DAY(CURDATE()), 8000.00, @admin_id, @admin_id),
  (@cat_empaques,      DATE_FORMAT(CURDATE(),'%Y-%m-01'), LAST_DAY(CURDATE()), 1500.00, @admin_id, @admin_id),
  (@cat_marketing,     DATE_FORMAT(CURDATE(),'%Y-%m-01'), LAST_DAY(CURDATE()),  800.00, @admin_id, @admin_id),
  (@cat_sueldos,       DATE_FORMAT(CURDATE(),'%Y-%m-01'), LAST_DAY(CURDATE()), 5000.00, @admin_id, @admin_id);

-- ==============================
-- 5. Ventas (muestran comisiones y neto)
-- ==============================
-- Regla aplicada:
--   comision = monto_total * (porcentaje_comision / 100)
--   monto_neto = monto_total - comision
-- Fechas distribuidas en el mes actual
INSERT INTO `ventas`
  (`id_canal`,`fecha`,`monto_total`,`comision`,`monto_neto`,`descripcion`,
   `usuario_creacion`,`usuario_modificacion`)
VALUES
  -- Mostrador (0% comisión)
  (@canal_mostrador, DATE_FORMAT(CURDATE(),'%Y-%m-02 12:30:00'),  450.00,  0.00,  450.00, 'Combo almuerzo x10', @admin_id, @admin_id),
  (@canal_mostrador, DATE_FORMAT(CURDATE(),'%Y-%m-03 19:45:00'),  680.00,  0.00,  680.00, 'Cena familiar',        @admin_id, @admin_id),

  -- Rappi (22%)
  (@canal_rappi,     DATE_FORMAT(CURDATE(),'%Y-%m-04 13:10:00'),  320.00,  70.40, 249.60, 'Pedidos variados',     @admin_id, @admin_id),
  (@canal_rappi,     DATE_FORMAT(CURDATE(),'%Y-%m-10 20:15:00'),  540.00, 118.80, 421.20, 'Promoción 2x1',       @admin_id, @admin_id),

  -- UberEats (25%)
  (@canal_ubereats,  DATE_FORMAT(CURDATE(),'%Y-%m-06 18:20:00'),  410.00, 102.50, 307.50, 'Tarde de antojos',     @admin_id, @admin_id),
  (@canal_ubereats,  DATE_FORMAT(CURDATE(),'%Y-%m-14 21:05:00'),  890.00, 222.50, 667.50, 'Evento deportivo',     @admin_id, @admin_id),

  -- PedidosYa (18%)
  (@canal_pedidosya, DATE_FORMAT(CURDATE(),'%Y-%m-08 12:05:00'),  270.00,  48.60, 221.40, 'Menú ejecutivo',       @admin_id, @admin_id),
  (@canal_pedidosya, DATE_FORMAT(CURDATE(),'%Y-%m-18 19:30:00'),  730.00, 131.40, 598.60, 'Fin de semana',        @admin_id, @admin_id);

-- ==============================
-- 6. Gastos (fijos y variables en el mes)
-- ==============================
INSERT INTO `gastos`
  (`id_categoria`,`descripcion`,`monto`,`comprobante`,
   `usuario_creacion`,`usuario_modificacion`,`fecha_creacion`)
VALUES
  -- Fijos
  (@cat_renta,     'Renta de local mes actual', 3000.00, 'FAC-REN-001', @admin_id, @admin_id, DATE_FORMAT(CURDATE(),'%Y-%m-01 09:00:00')),
  (@cat_servicios, 'Pago servicios públicos',  1150.00, 'FAC-SRV-014', @admin_id, @admin_id, DATE_FORMAT(CURDATE(),'%Y-%m-05 10:00:00')),
  (@cat_sueldos,   'Planilla quincena',        2500.00, 'NOM-001',     @admin_id, @admin_id, DATE_FORMAT(CURDATE(),'%Y-%m-15 08:00:00')),

  -- Variables
  (@cat_materia_prima, 'Compra papas y aceite', 2100.00, 'COMP-MP-077', @admin_id, @admin_id, DATE_FORMAT(CURDATE(),'%Y-%m-04 08:30:00')),
  (@cat_materia_prima, 'Reposición carnes/panes', 1850.00, 'COMP-MP-089', @admin_id, @admin_id, DATE_FORMAT(CURDATE(),'%Y-%m-12 09:00:00')),
  (@cat_empaques,      'Cajas/servilletas',      480.00,  'COMP-EMP-031', @admin_id, @admin_id, DATE_FORMAT(CURDATE(),'%Y-%m-07 11:00:00')),
  (@cat_marketing,     'Anuncios redes sociales', 350.00, 'MKT-ADS-210',  @admin_id, @admin_id, DATE_FORMAT(CURDATE(),'%Y-%m-09 14:30:00'));

-- ==============================
-- 7. Alertas (ejemplos)
-- ==============================
-- Ejemplo 1: gasto variable acercándose al presupuesto
INSERT INTO `alertas`
  (`id_categoria`,`fecha_alerta`,`descripcion`,`notificacion_abierta`,
   `usuario_creacion`,`usuario_modificacion`)
VALUES
  (@cat_materia_prima, DATE_FORMAT(CURDATE(),'%Y-%m-12 17:00:00'),
   'Materia prima alcanzó el 49% del presupuesto del mes', 0, @admin_id, @admin_id),

  (@cat_empaques, DATE_FORMAT(CURDATE(),'%Y-%m-20 10:15:00'),
   'Empaques superó el 80% del presupuesto mensual', 0, @admin_id, @admin_id);

SET FOREIGN_KEY_CHECKS = 1;


