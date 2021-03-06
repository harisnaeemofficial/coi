ENT.Base = "base_nextbot";

ENT.CopModels = {
	"models/player/nypd/cop_01.mdl",
	"models/player/nypd/cop_02.mdl",
	"models/player/nypd/cop_03.mdl",
	"models/player/nypd/cop_04.mdl",
	"models/player/nypd/cop_05.mdl",
	"models/player/nypd/cop_06.mdl",
	"models/player/nypd/cop_07.mdl",
	"models/player/nypd/cop_08.mdl",
	"models/player/nypd/cop_09.mdl",
};

function ENT:Initialize()

	self.AimDist = math.Rand( 500, 700 );
	self.AimDist = self.AimDist * self.AimDist; -- sqrt is expensive
	self.Accuracy = 0.06;

	if( SERVER ) then

		self:SetHealth( math.random( 10, 20 ) );

		self:SetName( "coi_cop_" .. self:EntIndex() );

		if( GAMEMODE:TimeLeftInState() < 150 ) then

			self:SetModel( "models/player/swat.mdl" );
			self.SMG = math.random( 1, 3 ) == 1;

		else

			local m = table.Random( self.CopModels );
			if( util.IsValidModel( m ) ) then
				self:SetModel( m );
			else
				self:SetModel( "models/player/swat.mdl" );
			end

		end

	end

end

function ENT:BodyUpdate()

	local act = self:GetActivity();

	if( act == ACT_RUN or act == ACT_WALK or act == ACT_HL2MP_RUN ) then

		self:BodyMoveXY();

	end
	
	self:FrameAdvance();

end

function ENT:OnKilled( dmg )

	self:BecomeRagdoll( dmg );
	self:SetAlive( false );
	
	local a = dmg:GetAttacker();

	if( a and a:IsValid() and a:IsPlayer() ) then

		a.Cops = ( a.Cops or 0 ) + 1;

	end

	local gun;

	if( self.SMG ) then

		gun = ents.Create( "weapon_coi_smg" );

	else

		gun = ents.Create( "weapon_coi_pistol" );

	end

	gun:SetPos( self:GetPos() + Vector( 0, 0, 48 ) );
	gun:SetAngles( Angle( math.Rand( -180, 180 ), math.Rand( -180, 180 ), math.Rand( -180, 180 ) ) );
	gun:Spawn();
	gun:Activate();

end

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Alive" );

	if( SERVER ) then
		self:SetAlive( true );
	end

end

function ENT:Alive()
	return self:GetAlive();
end
