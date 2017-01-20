within IDEAS.Buildings.Components.BaseClasses.RadiativeHeatTransfer;
model ZoneLwDistribution "internal longwave radiative heat exchange"

  parameter Integer nSurf(min=1) "Number of surfaces connected to the zone";

  parameter Boolean linearise=true "Linearise radiative heat exchange";
  parameter Modelica.SIunits.Temperature Tzone_nom = 295.15
    "Nominal temperature of environment, used for linearisation"
    annotation(Dialog(group="Linearisation", enable=linearise));
  parameter Modelica.SIunits.TemperatureDifference dT_nom = -2
    "Nominal temperature difference between solid and air, used for linearisation"
    annotation(Dialog(group="Linearisation", enable=linearise));

  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a[nSurf] port_a
    "Port for radiative heat exchange"
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));
  Modelica.Blocks.Interfaces.RealInput[nSurf] A(
     each final quantity="Area", each final unit="m2")
    "Surface areas of connected surfaces" annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={40,100})));
  Modelica.Blocks.Interfaces.RealInput[nSurf] epsLw(
     each final quantity="Emissivity", each final unit="1")
    "Longwave surface emissivities of connected surfaces" annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={0,100})));

protected
  parameter Real[nSurf] F(
     each final fixed=false,
     each final min=1e-6,
     each final max=1,
     each start=0.1)
    "View factor estimate for each surface";
  parameter Real[nSurf] R(
     each final fixed=false,
     each final unit="K4/W")
    "Thermal resistance for longwave radiative heat exchange";

  IDEAS.Buildings.Components.BaseClasses.RadiativeHeatTransfer.HeatRadiation[nSurf] radRes(
    R=R,
    each linearise=linearise,
    each dT_nom=dT_nom,
    each Tzone_nom=Tzone_nom)
    "Component that computes radiative heat exchange";

initial equation
  //see Eqns 29-30 in Liesen, R. J., & Pedersen, C. O. (1997). An Evaluation of Inside Surface Heat Balance Models for Cooling Load Calculations. ASHRAE Transactions, 3(103), 485–502.
  F=ones(nSurf)./(ones(nSurf)-A.*F/sum(A.*F));
  R=((ones(nSurf) - epsLw) ./ epsLw + ones(nSurf)./F) ./ A/ Modelica.Constants.sigma;

equation
  for i in 1:nSurf loop
    connect(radRes[i].port_b, port_a[i]);
  end for;

  for i in 1:nSurf - 1 loop
    connect(radRes[i].port_a, radRes[i + 1].port_a);
  end for;

  annotation (
    Diagram(graphics),
    Icon(graphics={
        Rectangle(
          extent={{-90,80},{90,-80}},
          pattern=LinePattern.None,
          fillColor={175,175,175},
          fillPattern=FillPattern.Backward,
          lineColor={0,0,0}),
        Rectangle(
          extent={{68,60},{-68,-60}},
          pattern=LinePattern.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          lineColor={0,0,0},
          lineThickness=0.5),
        Line(points={{-40,10},{40,10}}, color={191,0,0}),
        Line(points={{-40,10},{-30,16}}, color={191,0,0}),
        Line(points={{-40,10},{-30,4}}, color={191,0,0}),
        Line(points={{-40,-10},{40,-10}}, color={191,0,0}),
        Line(points={{30,-16},{40,-10}}, color={191,0,0}),
        Line(points={{30,-4},{40,-10}}, color={191,0,0}),
        Line(points={{-40,-30},{40,-30}}, color={191,0,0}),
        Line(points={{-40,-30},{-30,-24}}, color={191,0,0}),
        Line(points={{-40,-30},{-30,-36}}, color={191,0,0}),
        Line(points={{-40,30},{40,30}}, color={191,0,0}),
        Line(points={{30,24},{40,30}}, color={191,0,0}),
        Line(points={{30,36},{40,30}}, color={191,0,0}),
        Line(
          points={{-68,60},{68,60}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.None),
        Line(
          points={{68,60},{68,-60},{-68,-60},{-68,60}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.None)}),
    Documentation(info="<html>
<p>
The Mean Radiant Temperature Network (MRTnet) approach from 
Carroll (1980) is used to compute the radiative heat transfer.
This is a computationally efficient approach that does not require exact view factors to be known.
Each surface exchanges heat with a fictive radiant surface,
leading to a star resistance network.
</p>
<h4>References</h4>
<p>
Liesen, R. J., & Pedersen, C. O. (1997). An Evaluation of Inside Surface Heat Balance Models for Cooling Load Calculations. ASHRAE Transactions, 3(103), 485–502.
</p>
</html>", revisions="<html>
<ul>
<li>
January 20, 2017 by Filip Jorissen:<br/>
Changed view factor implementation.
See issue 
<a href=https://github.com/open-ideas/IDEAS/issues/643>#643</a>.
</li>
<li>
January 19, 2017 by Filip Jorissen:<br/>
Propagated parameters for linearisation.
</li>
<li>
July 12, 2016 by Filip Jorissen:<br/>
Changed implementation to be more intuitive.
Added units to variables.
</li>
</ul>
</html>"));
end ZoneLwDistribution;
