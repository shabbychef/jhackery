# Created: 2013.03.28
# Author: Steven E. Pav

## SCENARIO: fast moments?
# computation of moments and moment-based statistics
# 
# see also: 
# * http://www.johndcook.com/blog/2008/09/26/comparing-three-methods-of-computing-standard-deviation/
# * http://www.johndcook.com/standard_deviation.html
# * J. Bennett, et. al., 'Numerically Stable, Single-Pass,
#   Parallel Statistics Algorithms,' Proceedings of IEEE
#   International Conference on Cluster Computing, 2009.
#   http://www.janinebennett.org/index_files/ParallelStatisticsAlgorithms.pdf
# * T. Terriberry, 'Computing Higher-Order Moments Online,' 
#   http://people.xiph.org/~tterribe/notes/homs.html

# compute the kth moment of a vector based on the divide and conquer scheme from
# Bennett et. al.
# returns the number of elements, the mean, and 
# a (ord - 1)-vector consisting of the
# 2nd through ord'th centered sum, defined
# as sum_j (v[j] - mean)^i
# for i > 1
function rec_moments{T}(v::Array{T}, ord::Uint8)
	local n::T = convert(T,length(v))
	if n == 1
		return (n, v[1], zeros(T,ord-1,1))
	else
		local cut::Int = convert(Int,floor(0.5 * n))
		(n1,mu1,moms1) = rec_moments(v[1:cut],ord)
		(n2,mu2,moms2) = rec_moments(v[(cut+1):n],ord)
		# now stitch them together
		
		n = n1 + n2  # redundant
		local del21::T = mu2 - mu1
		local mu::T = mu1 + (n2 * del21 / n)   # eqn (II.3)
		local sum_mom::Array{T} = moms1 + moms2
		local nfoo::T = n1 * n2 * del21 / n
		for pp=2:ord
			sum_mom[pp-1] += (nfoo^pp) * ((n2^(1.0-pp)) - ((-n1)^(1.0-pp)))
			if (pp > 2)
				for kk=1:(pp - 2)
					sum_mom[pp-1] += binomial(pp,kk) * (del21^kk) * 
								(((-n2/n)^kk) * moms1[pp-kk-1] + ((n1/n)^kk) * moms2[pp-kk-1])
				end
			end
		end
		return (n, mu, sum_mom)
	end
end

# this is not working yet.
function moments{T}(v::Array{T}, ord::Uint8)
	local nel = length(v)
	local n::Array{T}
	local mu::Array{T} 
	local del21::Array{T}
	if (iseven(nel)) 
		n = repmat(convert(T,2),convert(Int,nel/2),1)
		del21 = v[2:2:end] - v[1:2:end]
		mu = (v[2:2:end] + v[1:2:end]) / 2
	else
		n = [repmat(convert(T,2),convert(Int,floor(nel/2)),1),1]
		del21 = [v[2:2:end] - v[1:2:(end-1)],v[end]];
		mu = [(v[2:2:end] + v[1:2:end]) / 2,v[end]];
	end

	# 2FIX: start here...
	while (length(n) > 1)


	end
end

# return the standard deviation, the mean and the dof
function std3{T}(v::Array{T})
	a,b,c = rec_moments(v,convert(Uint8,2))
	return (sqrt(c[1]/(a-1)),b,a)
end

# return the skew, the standard deviation, the mean, and the dof
function skew4{T}(v::Array{T})
	a,b,c = rec_moments(v,convert(Uint8,3))
	return (sqrt(a) * c[2] / (c[1]^1.5),
					sqrt(c[1]/(a-1)),b,a)
end

# return the //excess// kurtosis, skew, standard deviation, mean, and the dof
function kurt5{T}(v::Array{T})
	a,b,c = rec_moments(v,convert(Uint8,4))
	return ((a * c[3] / (c[1]^2.0)) - 3.0,
					sqrt(a) * c[2] / (c[1]^1.5),
					sqrt(c[1]/(a-1)),b,a)
end

# these are too slow ... 
x = randn(1000000);
@time aa,bb,cc = std3(x)
# elapsed time: 4.5228190422058105 seconds

@time aa,bb,cc,dd = skew4(x)
# elapsed time: 5.760412931442261 seconds

@time aa,bb,cc,dd,ee = kurt5(x)
# elapsed time: 7.608757972717285 seconds

#for vim modeline: (do not edit)
# vim:ts=2:sw=2:tw=79:fdm=indent:cms=#%s:tags=.tags;:syn=julia:ft=julia:ai:si:cin:nu:fo=croql:cino=p0t0c5(0:
