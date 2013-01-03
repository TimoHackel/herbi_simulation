clc;
clear all;
close all;

load_points = 'plant_points.txt'
save_urdf = 'generated_field.urdf'

add_noise = 1 % add noise to input points position?
mu = 0;
sigma = 0.02;

plant_visual = 'mesh filename="package://herbi_gazebo_worlds/ros/meshes/sunflower.dae"'
plant_visual_origin = 'origin xyz="0 0 0"'
plant_collision = 'cylinder length="0.4" radius="0.02"'
plant_collision_origin = 'origin xyz="0 0 0.2"'
%plant_collision = 'mesh filename="package://herbi_gazebo_worlds/ros/meshes/maizeplant_collision.dae"'
%plant_collision_origin = 'origin xyz="0 0 0"'


% read input point cloud
fid = fopen(load_points);
A = fscanf(fid, '%g %g %g', [3 inf]);
fclose(fid);
A = A';

if add_noise == 1
	 A = A + [normrnd(mu,sigma,[length( A ) 2]), zeros( length( A ), 1) ]
end

s = size(A);
if s(2) == 3
	%only points given, create random orientation.
	R = zeros( size(A) );
	for i=1:length(R)
		R(i,3) = rand(1) * 3.14;
	end
end

A = [A , R];
s = size(A);

if s(2) ~= 6
	fprint('load point list: either pass a list with 3 or 6 dof')
	exit();
end

% generate header
fid = fopen(save_urdf, 'w');

fprintf(fid, '<?xml version="1.0"?> \n<robot name="field"> \n <!-- auto generated urdf file --> \n <link name="dummy_link"> \n  <inertial> \n   <origin xyz="0 0 0" /> \n   <mass value="5.0" /> \n   <inertia ixx="0.0" ixy="0.0" ixz="0.0" iyy="0.0" iyz="0.0" izz="0.0" /> \n  </inertial> \n  <visual> \n   <origin xyz="0 0 0" /> \n   <geometry> \n    <box size="0.00 0.00 0.00" /> \n   </geometry> \n  </visual> \n  <collision> \n   <origin xyz="0 0 0" /> \n   <geometry> \n    <box size="0.00 0.00 0.00" /> \n   </geometry> \n  </collision> \n </link> \n \n \n <!-- generate plants -->');

for i=1:s(1)
	%link
	fprintf(fid, ' <link name="plant_%i">\n  <inertial>\n   <origin xyz="0 0 0" /> \n   <mass value="5.0" />\n   <inertia ixx="0.0" ixy="0.0" ixz="0.0" iyy="0.0" iyz="0.0" izz="0.0" />\n  </inertial>\n  <visual>\n   <%s/>\n   <geometry>\n    <%s/>\n   </geometry>\n  </visual>\n  <collision>\n   <%s/>\n   <geometry>\n    <%s/>\n   </geometry>\n  </collision>\n </link>\n\n', i,plant_visual_origin,plant_visual,plant_collision_origin,plant_collision);

	%joint
	fprintf(fid, ' <joint name="joint_plant_%i" type="fixed">\n  <origin xyz="%f %f %f" rpy="%f %f %f" />\n  <parent link="dummy_link" />\n  <child link="plant_%i" />\n </joint>\n\n\n', i, A(i,1), A(i,2), A(i,3), A(i,4), A(i,5), A(i,6), i);
	
end

%urdf footer:
fprintf(fid, '\n\n</robot>');

%end file:
fclose(fid);
