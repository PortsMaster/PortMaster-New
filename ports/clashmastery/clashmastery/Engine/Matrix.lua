local Matrix = {}

function Matrix.initialize()
    -- Useful for multiplying matrices without generating a ton of garbage
    Matrix.tempMatrix = {
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0
    }
end

function Matrix.identityMatrix()
    return {
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1
    }
end

function Matrix.transpose(mat)
    Matrix.tempMatrix[1]  = mat[1]
    Matrix.tempMatrix[2]  = mat[5]
    Matrix.tempMatrix[3]  = mat[9]
    Matrix.tempMatrix[4]  = mat[13]
    Matrix.tempMatrix[5]  = mat[2]
    Matrix.tempMatrix[6]  = mat[6]
    Matrix.tempMatrix[7]  = mat[10]
    Matrix.tempMatrix[8]  = mat[14]
    Matrix.tempMatrix[9]  = mat[3]
    Matrix.tempMatrix[10] = mat[7]
    Matrix.tempMatrix[11] = mat[11]
    Matrix.tempMatrix[12] = mat[15]
    Matrix.tempMatrix[13] = mat[4]
    Matrix.tempMatrix[14] = mat[8]
    Matrix.tempMatrix[15] = mat[12]
    Matrix.tempMatrix[16] = mat[16]
    Matrix.copyInto(Matrix.tempMatrix, mat)
end

function Matrix.inverse(mat)
	Matrix.tempMatrix[1]  = mat[6] * mat[11] * mat[16] - mat[6] * mat[12] * mat[15] - mat[10] * mat[7] * mat[16] + mat[10] * mat[8] * mat[15] + mat[14] * mat[7] * mat[12] - mat[14] * mat[8] * mat[11]
	Matrix.tempMatrix[5]  =-mat[5] * mat[11] * mat[16] + mat[5] * mat[12] * mat[15] + mat[9]  * mat[7] * mat[16] - mat[9]  * mat[8] * mat[15] - mat[13] * mat[7] * mat[12] + mat[13] * mat[8] * mat[11]
	Matrix.tempMatrix[9]  = mat[5] * mat[10] * mat[16] - mat[5] * mat[12] * mat[14] - mat[9]  * mat[6] * mat[16] + mat[9]  * mat[8] * mat[14] + mat[13] * mat[6] * mat[12] - mat[13] * mat[8] * mat[10]
	Matrix.tempMatrix[13] =-mat[5] * mat[10] * mat[15] + mat[5] * mat[11] * mat[14] + mat[9]  * mat[6] * mat[15] - mat[9]  * mat[7] * mat[14] - mat[13] * mat[6] * mat[11] + mat[13] * mat[7] * mat[10]
	Matrix.tempMatrix[2]  =-mat[2] * mat[11] * mat[16] + mat[2] * mat[12] * mat[15] + mat[10] * mat[3] * mat[16] - mat[10] * mat[4] * mat[15] - mat[14] * mat[3] * mat[12] + mat[14] * mat[4] * mat[11]
	Matrix.tempMatrix[6]  = mat[1] * mat[11] * mat[16] - mat[1] * mat[12] * mat[15] - mat[9]  * mat[3] * mat[16] + mat[9]  * mat[4] * mat[15] + mat[13] * mat[3] * mat[12] - mat[13] * mat[4] * mat[11]
	Matrix.tempMatrix[10] =-mat[1] * mat[10] * mat[16] + mat[1] * mat[12] * mat[14] + mat[9]  * mat[2] * mat[16] - mat[9]  * mat[4] * mat[14] - mat[13] * mat[2] * mat[12] + mat[13] * mat[4] * mat[10]
	Matrix.tempMatrix[14] = mat[1] * mat[10] * mat[15] - mat[1] * mat[11] * mat[14] - mat[9]  * mat[2] * mat[15] + mat[9]  * mat[3] * mat[14] + mat[13] * mat[2] * mat[11] - mat[13] * mat[3] * mat[10]
	Matrix.tempMatrix[3]  = mat[2] * mat[7]  * mat[16] - mat[2] * mat[8]  * mat[15] - mat[6]  * mat[3] * mat[16] + mat[6]  * mat[4] * mat[15] + mat[14] * mat[3] * mat[8]  - mat[14] * mat[4] * mat[7]
	Matrix.tempMatrix[7]  =-mat[1] * mat[7]  * mat[16] + mat[1] * mat[8]  * mat[15] + mat[5]  * mat[3] * mat[16] - mat[5]  * mat[4] * mat[15] - mat[13] * mat[3] * mat[8]  + mat[13] * mat[4] * mat[7]
	Matrix.tempMatrix[11] = mat[1] * mat[6]  * mat[16] - mat[1] * mat[8]  * mat[14] - mat[5]  * mat[2] * mat[16] + mat[5]  * mat[4] * mat[14] + mat[13] * mat[2] * mat[8]  - mat[13] * mat[4] * mat[6]
	Matrix.tempMatrix[15] =-mat[1] * mat[6]  * mat[15] + mat[1] * mat[7]  * mat[14] + mat[5]  * mat[2] * mat[15] - mat[5]  * mat[3] * mat[14] - mat[13] * mat[2] * mat[7]  + mat[13] * mat[3] * mat[6]
	Matrix.tempMatrix[4]  =-mat[2] * mat[7]  * mat[12] + mat[2] * mat[8]  * mat[11] + mat[6]  * mat[3] * mat[12] - mat[6]  * mat[4] * mat[11] - mat[10] * mat[3] * mat[8]  + mat[10] * mat[4] * mat[7]
	Matrix.tempMatrix[8]  = mat[1] * mat[7]  * mat[12] - mat[1] * mat[8]  * mat[11] - mat[5]  * mat[3] * mat[12] + mat[5]  * mat[4] * mat[11] + mat[9]  * mat[3] * mat[8]  - mat[9]  * mat[4] * mat[7]
	Matrix.tempMatrix[12] =-mat[1] * mat[6]  * mat[12] + mat[1] * mat[8]  * mat[10] + mat[5]  * mat[2] * mat[12] - mat[5]  * mat[4] * mat[10] - mat[9]  * mat[2] * mat[8]  + mat[9]  * mat[4] * mat[6]
	Matrix.tempMatrix[16] = mat[1] * mat[6]  * mat[11] - mat[1] * mat[7]  * mat[10] - mat[5]  * mat[2] * mat[11] + mat[5]  * mat[3] * mat[10] + mat[9]  * mat[2] * mat[7]  - mat[9]  * mat[3] * mat[6]

	local det = mat[1] * Matrix.tempMatrix[1] + mat[2] * Matrix.tempMatrix[5] + mat[3] * Matrix.tempMatrix[9] + mat[4] * Matrix.tempMatrix[13]
	Matrix.copyInto(Matrix.tempMatrix, mat)

	if det ~= 0.0 then
		local invdet = 1.0 / det
		for i = 1, 16 do
			mat[i] = mat[i] * invdet
		end
	end
end

function Matrix.setFromTRS2(matrix, tx, ty, tz, rx, ry, rz, rw, sx, sy, sz)
	local x, y, z, w = rx, ry, rz, rw
	local x2, y2, z2 = x + x, y + y, z + z

	local xx, xy, xz = x * x2, x * y2, x * z2
	local yy, yz, zz = y * y2, y * z2, z * z2
	local wx, wy, wz = w * x2, w * y2, w * z2

	matrix[1]  = (1 - (yy + zz)) * sx
	matrix[2]  = (xy + wz) * sx
	matrix[3]  = (xz - wy) * sx
	matrix[4]  = 0
	matrix[5]  = (xy - wz) * sy
	matrix[6]  = (1 - (xx + zz)) * sy
	matrix[7]  = (yz + wx) * sy
	matrix[8]  = 0
	matrix[9]  = (xz + wy) * sz
	matrix[10] = (yz - wx) * sz
	matrix[11] = (1 - (xx + yy)) * sz
	matrix[12] = 0
	matrix[13] = tx
	matrix[14] = ty
	matrix[15] = tz
	matrix[16] = 1
    Matrix.transpose(matrix)
end

function Matrix.setFromTRS(matrix, x, y, z, rx, ry, rz, rw, sx, sy, sz)
    -- https://github.com/groverburger/g3d/blob/master/g3d/matrices.lua "setTransformationMatrix"
    -- translation
    matrix[4] = x
    matrix[8] = y
    matrix[12] = z

    -- rotation
    if not rw then -- Not using quaternion
        -- use 3D rotation vector as euler angles
        -- source: https://en.wikipedia.org/wiki/Rotation_matrix
        local ca, cb, cc = math.cos(rz), math.cos(ry), math.cos(rx)
        local sa, sb, sc = math.sin(rz), math.sin(ry), math.sin(rx)
        matrix[1], matrix[2],  matrix[3]  = ca*cb, ca*sb*sc - sa*cc, ca*sb*cc + sa*sc
        matrix[5], matrix[6],  matrix[7]  = sa*cb, sa*sb*sc + ca*cc, sa*sb*cc - ca*sc
        matrix[9], matrix[10], matrix[11] = -sb, cb*sc, cb*cc
    else
        -- use 4D rotation vector as a quaternion
        local qx, qy, qz, qw = rx, ry, rz, rw
        matrix[1], matrix[2],  matrix[3]  = 1 - 2*qy^2 - 2*qz^2, 2*qx*qy - 2*qz*qw,   2*qx*qz + 2*qy*qw
        matrix[5], matrix[6],  matrix[7]  = 2*qx*qy + 2*qz*qw,   1 - 2*qx^2 - 2*qz^2, 2*qy*qz - 2*qx*qw
        matrix[9], matrix[10], matrix[11] = 2*qx*qz - 2*qy*qw,   2*qy*qz + 2*qx*qw,   1 - 2*qx^2 - 2*qy^2
    end

    -- scale
    matrix[1], matrix[2],  matrix[3]  = matrix[1] * sx, matrix[2]  * sy, matrix[3]  * sz
    matrix[5], matrix[6],  matrix[7]  = matrix[5] * sx, matrix[6]  * sy, matrix[7]  * sz
    matrix[9], matrix[10], matrix[11] = matrix[9] * sx, matrix[10] * sy, matrix[11] * sz

    -- fourth row is not used, just set it to the fourth row of the identity matrix
    matrix[13], matrix[14], matrix[15], matrix[16] = 0, 0, 0, 1
end

function Matrix.multiplyInto(a, b, into)
    -- https://github.com/rozenmad/Menori/blob/dev/menori/modules/ml/modules/mat4.lua
	-- EDITED: TO BE ROW-MAJOR AHHHHHHH
    Matrix.tempMatrix[1]  = a[1] * b[1]  + a[2] * b[5]  + a[3]  * b[9]  + a[4] * b[13]
    Matrix.tempMatrix[2]  = a[1] * b[2]  + a[2] * b[6]  + a[3]  * b[10] + a[4] * b[14]
    Matrix.tempMatrix[3]  = a[1] * b[3]  + a[2] * b[7]  + a[3]  * b[11] + a[4] * b[15]
    Matrix.tempMatrix[4]  = a[1] * b[4]  + a[2] * b[8]  + a[3]  * b[12] + a[4] * b[16]
    Matrix.tempMatrix[5]  = a[5] * b[1]  + a[6] * b[5]  + a[7]  * b[9]  + a[8] * b[13]
    Matrix.tempMatrix[6]  = a[5] * b[2]  + a[6] * b[6]  + a[7]  * b[10] + a[8] * b[14]
    Matrix.tempMatrix[7]  = a[5] * b[3]  + a[6] * b[7]  + a[7]  * b[11] + a[8] * b[15]
    Matrix.tempMatrix[8]  = a[5] * b[4]  + a[6] * b[8]  + a[7]  * b[12] + a[8] * b[16]
    Matrix.tempMatrix[9]  = a[9] * b[1]  + a[10] * b[5] + a[11] * b[9]  + a[12] * b[13]
    Matrix.tempMatrix[10] = a[9] * b[2]  + a[10] * b[6] + a[11] * b[10] + a[12] * b[14]
    Matrix.tempMatrix[11] = a[9] * b[3]  + a[10] * b[7] + a[11] * b[11] + a[12] * b[15]
    Matrix.tempMatrix[12] = a[9] * b[4]  + a[10] * b[8] + a[11] * b[12] + a[12] * b[16]
    Matrix.tempMatrix[13] = a[13] * b[1] + a[14] * b[5] + a[15] * b[9]  + a[16] * b[13]
    Matrix.tempMatrix[14] = a[13] * b[2] + a[14] * b[6] + a[15] * b[10] + a[16] * b[14]
    Matrix.tempMatrix[15] = a[13] * b[3] + a[14] * b[7] + a[15] * b[11] + a[16] * b[15]
    Matrix.tempMatrix[16] = a[13] * b[4] + a[14] * b[8] + a[15] * b[12] + a[16] * b[16]

    into = into or a
    for i = 1, 16 do
        into[i] = Matrix.tempMatrix[i]
    end
end

function Matrix.copyInto(from, to)
    for k = 1,16 do
        to[k] = from[k]
    end
end

return Matrix